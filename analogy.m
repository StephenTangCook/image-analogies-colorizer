function [ analogy_image ] = analogy( imgA, imgAp, imgB, neighborhood_size, brute_force, remap_lum, resultsFigPathPrefix, levels )
%analogy Carries out image analogies with given image pairs.
%   A:Ap::B:Bp
%  Get image from figure: imwrite(getimage(h(3)), 'COLOR2.png', 'png');

%% Image Analogies
fprintf('Image analogies with %d levels:\n', levels);

%% Parameters
%Printing the progress (percent of pixels in Bp completed)
show_results = 1; %display analogy results
print_progress = 1; %print progress of synthesizing pixels in Bp
percent_increase_print = 0.10; %amount for progress to increase when printing
reremap_lum = 1; %if remapping lum, re-remap afterwards to match B
showPyramid = 0;
smaller_scale_neighborhood_size = 3; %n size for the scaled down resolution

%brute_force = 0;
entire_pixel_from_Ap = 1; %show results if you took YIQ all from Ap

%ANN parameters
eps = 1.0; %accuracy multiplicative factor
k = 1; %number of nearest neighbor(s) to find

%% Read in images
%Start timer
% tic

%Read in images, if not already
if ischar(imgA)
    imgA = imread(imgA);
end
if ischar(imgAp)
    imgAp = imread(imgAp);
end
if ischar(imgB)
    imgB = imread(imgB);
end

%Convert image format from [1-256] form to double [0.0-1.0] rgb form
%Add RGB channels if grayscale
imgA = addRGBchannels(im2double(imgA));
imgAp = addRGBchannels(im2double(imgAp));
imgB = addRGBchannels(im2double(imgB));

%Compute Gaussian pyramid for images
AllLevelsA = computeGaussianPyramid(imgA, levels, showPyramid);
AllLevelsAp = computeGaussianPyramid(imgAp, levels, showPyramid);
AllLevelsB = computeGaussianPyramid(imgB, levels, showPyramid);

%Clear vars
clearvars imgA imgAp imgB;

%% Do this for all levels
for l=1:levels
    fprintf('Starting Level %d image analogy.\n', l);
    %Add RGB channels if grayscale
    A.raw = AllLevelsA{l};
    Ap.raw = AllLevelsAp{l};
    B.raw = AllLevelsB{l};
    
    %% Get the features (luminance)
    %Calculate luminance values as feature vectors for each pixel
    A.features = convertToLuminance(A.raw);
    Ap.features = convertToLuminance(Ap.raw);
    B.features = convertToLuminance(B.raw);

    %% Remap luminance?
    if remap_lum
        fprintf('Remapping luminance of A and Ap to match B...\n');
        %For A:
        A.features = remap_luminance(A.features, B.features);
        %For Ap:
        Ap.features = remap_luminance(Ap.features, B.features);
    else
        fprintf('NOT remapping luminance of A and Ap...\n');
    end

    %% Compute feature vectors at each pixel
    %Precompute concatenated feature vectors of KxK neighborhood for each pixel
    fprintf('Processing feature vectors for A, Ap, and B.\n');
    A.fvectors = computeFeatureVectors(A.features, neighborhood_size, 'full');
    Ap.fvectors = computeFeatureVectors(Ap.features, neighborhood_size, 'partial');
    B.fvectors = computeFeatureVectors(B.features, neighborhood_size, 'full');
    
    if l > 1
        %Compute the fvectors of the previous smaller scaled level
        PreviousLevel.A.fvectors = computeFeatureVectors(PreviousLevel.A.features, smaller_scale_neighborhood_size, 'full');
        PreviousLevel.B.fvectors = computeFeatureVectors(PreviousLevel.B.features, smaller_scale_neighborhood_size, 'full');
        PreviousLevel.Ap.fvectors = computeFeatureVectors(PreviousLevel.Ap.features, smaller_scale_neighborhood_size, 'full');
        PreviousLevel.Bp.fvectors = computeFeatureVectors(PreviousLevel.Bp.features, smaller_scale_neighborhood_size, 'full');
        %Prepare ANN points for the A+Ap+PreviousLevel fvectors
        annPts = createANNmatrixWithPreviousLevel(A.fvectors, PreviousLevel.A.fvectors, ...
                                        Ap.fvectors, PreviousLevel.Ap.fvectors, ...
                                        neighborhood_size, smaller_scale_neighborhood_size);
        anno = ann(annPts);
    else
        %Prepare ANN points for the A+Ap fvectors
        annPts = createANNmatrix(A.fvectors, Ap.fvectors, neighborhood_size);
        anno = ann(annPts);
    end
    
    %% Bp initialization
    numRowsB = size(B.features,1);
    numColsB = size(B.features,2);
    halfNeighborhoodSize = floor(neighborhood_size/2);

    %Create initial matrix of -1
    Bp.raw = zeros(numRowsB, numColsB, 3);
    Bp.features = ones(numRowsB + halfNeighborhoodSize*2, ...
                        numColsB + halfNeighborhoodSize*2) * -1;

    %Copy over boundary features from B to Bp?
    % default_value = 0.5; %average luminance?
    % numRowsBp = size(Bp.features,1);
    % numColsBp = size(Bp.features,2);
    % Bp.features(1:halfNeighborhoodSize,:) = default_value;
    % Bp.features(numRowsBp-halfNeighborhoodSize+1:numRowsBp,:) = default_value;
    % Bp.features(:, 1:halfNeighborhoodSize) = default_value;
    % Bp.features(:, numColsBp-halfNeighborhoodSize+1:numColsBp) = default_value;

    %This Bp takes YIQ all from Ap
    if entire_pixel_from_Ap
        %Create default matrix of -1
        Bp_colorsFromAp.raw = zeros(numRowsB, numColsB, 3);
    end

    %Src tracks where in Ap each pixel in Bp came from
    Src.raw = zeros(numRowsB, numColsB, 3);

    %% Synthesize pixels in Bp
    fprintf('Synthesizing pixels in Bp.\n');
    %Do not include the mirrored padding in pixel synthesis
    px = 0;
    prev_percent = 0;
    num_pixels_B = numRowsB*numColsB;
    for i=1:numRowsB
        for j=1:numColsB
            %Get fvector at the corresponding pixel location in B
            b = B.fvectors(i, j, :);
            fVectorB(1,:) = b(:,:,:);

            %Get partial fvector of the top L-section in Bp
            fVectorBp = computeBpFeatureVector(Bp.features, ...
                            neighborhood_size, ...
                            i+halfNeighborhoodSize, j+halfNeighborhoodSize);

            %Find best match in A and Ap with this B+Bp fvector
            if brute_force
                min_difference = findBestMatchBrute(fVectorB, fVectorBp, ...
                                    A, Ap, neighborhood_size);
            else
                if l>1 % Use previous level
                    smaller_scale_numRowsB = size(PreviousLevel.B.fvectors,1);
                    smaller_scale_numColsB = size(PreviousLevel.B.fvectors,2);
                    [ii,jj] = getCorrespondingCoord(numRowsB, numColsB, ...
                        smaller_scale_numRowsB, smaller_scale_numColsB, i, j);
                    
                    %Get fvector at the corresponding pixel location in
                    %small_B/Bp
                    s_b = PreviousLevel.B.fvectors(ii, jj, :);
                    smaller_scale_fVectorB(1,:) = s_b(:,:,:);
                    s_bp = PreviousLevel.Bp.fvectors(ii, jj, :);
                    smaller_scale_fVectorBp(1,:) = s_bp(:,:,:);
                    
                    min_difference = findBestMatchANNwithPreviousLevel(fVectorB, smaller_scale_fVectorB, ...
                        fVectorBp, smaller_scale_fVectorBp, ...
                        A, Ap, neighborhood_size, smaller_scale_neighborhood_size, ...
                        anno, annPts, k, eps);
                else %Smallest level, or only one level
                    min_difference = findBestMatchANN(fVectorB, fVectorBp, ...
                        A, Ap, neighborhood_size, anno, annPts, k, eps);
                end
            end

            %Put the best matched pixel's luminance in Bp
            Y = Ap.features(min_difference.i, min_difference.j);
            Bp.features(i+halfNeighborhoodSize,j+halfNeighborhoodSize) = Y;
            
            %Only need to calculate RGB/YIQ info for final level for Bp.raw
            if l == levels
                %Src matrix (where did this Bp pixel come from in Ap?)
                Src.raw(i,j,1) = min_difference.i; %x-coord controls red value
                Src.raw(i,j,2) = min_difference.j; %y-coord controls green value

                %% Copy over YIQ information
                if entire_pixel_from_Ap
                    %Copy all pixel color information from Ap pixel to Bp_colorsFromAp
                    rgb(1,:) = Ap.raw(min_difference.i, min_difference.j,:);
                    Bp_colorsFromAp.raw(i,j,:) = rgb(:,:,:);
                end

                %Copy Y from B, and IQ from Ap
                ii = min_difference.i;
                jj = min_difference.j;
                Y = B.features(i,j);
                I = getI(Ap.raw(ii,jj,1),Ap.raw(ii,jj,2),Ap.raw(ii,jj,3));
                Q = getQ(Ap.raw(ii,jj,1),Ap.raw(ii,jj,2),Ap.raw(ii,jj,3));
                Bp.raw(i,j,:) = convertYIQtoRGB(Y,I,Q);
            end

            %Print progress so far in Bp
            px = px + 1;
            percent = (px/num_pixels_B);
            %fprintf('Pixel %d at (%d,%d)\n', px, i ,j); %print each pixel
            if (print_progress) && (percent >= prev_percent + percent_increase_print)
                fprintf('\t%3.2f percent pixels synthesized...\n', percent*100);
                prev_percent = percent;
            end

        end
    end

    fprintf('Level %d complete.\n', l);
    
    %Set information for the next level up
    PreviousLevel.A.features = A.features;
    PreviousLevel.Ap.features = Ap.features;
    PreviousLevel.B.features = B.features;
    %Get rid of padding
    Bp.features = Bp.features(halfNeighborhoodSize+1:halfNeighborhoodSize+numRowsB,...
                            halfNeighborhoodSize+1:halfNeighborhoodSize+numColsB);
    PreviousLevel.Bp.features = Bp.features;
    
    %TODO remove level-2 stuff? ANNmatrix, AllLevels/PreviousLevel{l-2}, Apfvectors,
    %Bpfvectors
    if l > 2
        %Clear unnecessary info from level (l-2)
        AllLevelsA{l-1} = [];
        AllLevelsAp{l-1} = [];
        AllLevelsB{l-1} = [];
    end
end

fprintf('Done. Image analogy completed!\n');

%Remap luminance back to similar B stats
if remap_lum && reremap_lum
    fprintf('Remapping luminance of Bp back to match B statistics.\n');
    Bp_colorsFromAp.raw = remap_luminance_from_RGB(B.raw, Bp_colorsFromAp.raw);
end

%End timer
% toc

%% Display analogy results
if show_results
    figure;
    %A
    subplot(3,2,1);
    imshow(A.raw);
    title('A');

    %Ap
    subplot(3,2,2);
    imshow(Ap.raw);
    title('Ap');

    %B
    subplot(3,2,3);
    imshow(B.raw);
    title('B');

    %Bp
    subplot(3,2,5);
    imshow(Bp.raw);
    if remap_lum
        title('Bp (Y:B, IQ:Ap). Lum remapped.');
    else
        title('USING Bp (Y:B, IQ:Ap). Lum NOT remap.');
    end
    
    %Bp_colorsFromAp
    if entire_pixel_from_Ap
        subplot(3,2,4);
        imshow(Bp_colorsFromAp.raw);
        if remap_lum
            title('USING Bp (YIQ:Ap). Lum remapped.');
        else
            title('Bp (YIQ:Ap) Lum NOT remap.');
        end
    end

    %Src
    Src.raw(:,:,1) = Src.raw(:,:,1)./size(Ap.raw,1);
    Src.raw(:,:,2) = Src.raw(:,:,2)./size(Ap.raw,2);
    subplot(3,2,6);
    imshow(Src.raw);
    title('Src ');
    
    %Save figure to file
    savefig(strcat(resultsFigPathPrefix,'.analogy.fig'));
end

%Return the version with Bp.raw for NOT remapped and Bp_allFromAp for lum remapped?
if remap_lum
    analogy_image = Bp_colorsFromAp.raw;
else %not remmapped
    analogy_image = Bp.raw;
end

end