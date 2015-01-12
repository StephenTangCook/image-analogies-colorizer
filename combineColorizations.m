function [ combined ] = combineColorizations( all_analogy_colorizations, comboType )
%combineColorizations Maintains the most vibrant colors of two images when
%combining RGB values.
%   Detailed explanation goes here

%% Parameters
% addColors = 0;
averageColors = 0;
weightedVibrance = 0;
numImages = size(all_analogy_colorizations,2);
equalWeight = 1.0/numImages;

%What is the combination type?
if strcmp(comboType, 'average')
    averageColors = 1;
elseif strcmp(comboType, 'vibrance')
    weightedVibrance = 1;
else %default is simple average
    averageColors = 1;
end


%% Read in images
%Read in images if not done already
for i=1:numImages
    if ischar(all_analogy_colorizations{i})
        all_analogy_colorizations{i} = im2double(imread(all_analogy_colorizations{i}));
    end
end

%Assumes they are all the same size
numRows = size(all_analogy_colorizations{1},1);
numCols = size(all_analogy_colorizations{1},2);
combined = zeros(numRows, numCols, 3);

if averageColors
    final_colorization = all_analogy_colorizations{1};
    for i = 2:numImages
        final_colorization = cat(4, final_colorization, all_analogy_colorizations{i});     
    end
    combined = mean(final_colorization, 4); %average
elseif weightedVibrance
    %% Get RGB channel info from each image
    sumR = zeros(numRows, numCols);
    sumG = zeros(numRows, numCols);
    sumB = zeros(numRows, numCols);
    sumDistanceToGray = zeros(numRows, numCols);
    ALL = cell(1,numImages);
    for i=1:numImages
        %RGB channels
        imgA = all_analogy_colorizations{i};
        r = imgA(:,:,1);
        g = imgA(:,:,2);
        b = imgA(:,:,3);
        distToGray = abs(r-g)+abs(r-b)+abs(g-b);
        ALL{i}.distToGray = distToGray;
        ALL{i}.r = r;
        ALL{i}.g = g;
        ALL{i}.b = b;

        % Running sums
        sumR = sumR + r;
        sumG = sumG + g;
        sumB = sumB + b;
        sumDistanceToGray = sumDistanceToGray + distToGray;
    end

    %% Calculate average in each channel
    avgR = sumR/numImages;
    avgG = sumG/numImages;
    avgB = sumB/numImages;

    %% Combine weighted RGB
    newR = avgR;
    newG = avgG;
    newB = avgB;
    for i=1:numImages
        r = ALL{i}.r;
        g = ALL{i}.g;
        b = ALL{i}.b;
        distToGray = ALL{i}.distToGray;
        distToAvgR = r-avgR;
        distToAvgG = g-avgG;
        distToAvgB = b-avgB;

        weight = distToGray./sumDistanceToGray;
        % Remove NaNs
        weight(isnan(weight)) = equalWeight;

        avg_weight = mean2(weight);
        fprintf('\tWeight (average over all pixels) for image %d: %3.2f\n', i, avg_weight);

        newR = newR + weight.*distToAvgR;
        newG = newG + weight.*distToAvgG;
        newB = newB + weight.*distToAvgB;
    end

    combined(:,:,1)= newR;
    combined(:,:,2)= newG;
    combined(:,:,3)= newB;
end

end

