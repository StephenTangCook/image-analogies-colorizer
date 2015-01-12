function [ annMatrix ] = createANNmatrixWithPreviousLevel( Afvectors, PreviousLevelAfvectors, Apfvectors, PreviousLevelApfvectors, neighborhood_size, smaller_scale_neighborhood_size )
%createANNmatrix Creates matrix of dxN ANN points (N points of
%d-dimensions). Combines fvectors of A with partial fvectors of Ap along
%with the corresponding fvectors of the previous level.
%   Detailed explanation goes here

%% Calculate dimensions
numRows = size(Afvectors,1);
numCols = size(Afvectors,2);
numPixels = numRows * numCols;
full_neighborhood = neighborhood_size*neighborhood_size;
halfNeighborhoodSize = floor(full_neighborhood/2);

%Smaller resolution level
smaller_scale_numRows = size(PreviousLevelAfvectors,1);
smaller_scale_numCols = size(PreviousLevelAfvectors,2);
smaller_scale_full_neighborhood = smaller_scale_neighborhood_size*smaller_scale_neighborhood_size;
%smaller_scale_halfNeighborhoodSize = floor(smaller_scale_full_neighborhood/2);

%% Compute Gaussian weights (for each neighborhood)
%A + Ap + smaller_A + smaller+Ap
gauss_matrix = fspecial('gaussian', neighborhood_size);
gauss_weights = reshape(gauss_matrix.',1,[]); % single vector form
partial_gauss_weights = gauss_weights(1, 1:halfNeighborhoodSize);
concatGaussWeights = [gauss_weights partial_gauss_weights];
%square root of the gaussian weights
concatGaussWeightsSR = sqrt(concatGaussWeights);

%Both smaller_A and smaller_Ap use full neighborhoods
gauss_matrix = fspecial('gaussian', smaller_scale_neighborhood_size);
gauss_weights = reshape(gauss_matrix.',1,[]); % single vector form
smaller_scale_concatGaussWeights = [gauss_weights gauss_weights];
%square root of the gaussian weights
smaller_scale_concatGaussWeightsSR = sqrt(smaller_scale_concatGaussWeights);

concatGaussWeightsSR = [concatGaussWeightsSR smaller_scale_concatGaussWeightsSR];

%Initially Nxd matrix, will transpose later
%A+Ap + smaller_A + smaller+Ap
total_vector_length = full_neighborhood + halfNeighborhoodSize + 2*smaller_scale_full_neighborhood;
annMatrix = zeros(numPixels,total_vector_length);

%% Get neighborhood features for each pixel, weight with sqrt Gaussian
px = 1;
for i=1:numRows
    for j=1:numCols
        %Get corresponding coord of smaller level
        [ii,jj] = getCorrespondingCoord(numRows, numCols, smaller_scale_numRows, smaller_scale_numCols, i, j);
        
        %Get fvector from A
        fvector = Afvectors(i,j,:);
        a(1,:) = fvector;

        %Get fvector from Ap
        fvector = Apfvectors(i,j,:);
        ap(1,:) = fvector;
        
        try
            %Get fvector from smaller_A
            fvector = PreviousLevelAfvectors(ii,jj,:);
            smaller_scale_a(1,:) = fvector;

            %Get fvector from smaller_Ap
            fvector = PreviousLevelApfvectors(ii,jj,:);
            smaller_scale_ap(1,:) = fvector;
        
        catch err
            fprintf('(i,j) = (%d,%d)\n', i,j);
            fprintf('(ii,jj) = (%d,%d)\n', ii,jj);
            msg = 'i and j';
            error('MATLAB:myCode:dimensions', msg);
        end
        
        %Combine fvectors horizontally, weight with sqrt of Gauss
        a_ap = [a ap smaller_scale_a smaller_scale_ap].*concatGaussWeightsSR;
        
        %Add fvector (point) to matrix
        annMatrix(px,:) = a_ap;
        px = px + 1;
    end
end

annMatrix = annMatrix';

end

