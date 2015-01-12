function [ fvectors ] = computeFeatureVectors( features, neighborhood_size, fullness )
%computeFeatureVectors Computes the concatenated features for each pixel
%   according to its neighborhood size
%   This is for full KxK neighborhoods.

%% Compute vector dimensions
numRows = size(features,1);
numCols = size(features,2);
vectorSize = neighborhood_size * neighborhood_size;
halfNeighborhoodSize = floor(neighborhood_size/2);
partial = 0;

%% Add padding to the boundaries of the features matrix by mirroring edges
% Mirror the top/bottom edges
padded_features = padarray(features, halfNeighborhoodSize, ...
                    'symmetric', 'both');
%Mirror left/right edges by transposing matrix and repeating
padded_features = padarray(padded_features.', halfNeighborhoodSize, ...
                    'symmetric', 'both');
%Transpose matrix back to original position
padded_features = padded_features.';

%Partial neighborhood for the top-left L-shape pixels
if strcmp(fullness, 'partial')
    partial = 1;
    vectorSize = floor(vectorSize/2);
end
fvectors = zeros(numRows, numCols, vectorSize); %start with zeros

%Each neighborhood pixel is numbered starting top-left. For example 3x3:
%1 2 3
%4 5 6
%7 8 9

%% Iterate through all pixels
%Start within the padded area
for i=halfNeighborhoodSize+1:numRows
    for j=halfNeighborhoodSize+1:numCols
        %Get the neighborhood of pixels around it
        neighborhood = ...
            padded_features(i-halfNeighborhoodSize:i+halfNeighborhoodSize, ...
            j-halfNeighborhoodSize:j+halfNeighborhoodSize);
        %Convert this KxK neighborhood into a horizontal vector
        vector = reshape(neighborhood.',1,[]);
        
        %Partial neighborhood for the top-left L-shape pixels
        if partial
            vector = vector(1,1:vectorSize);
        end
        
        %Save this concatenated feature vector at correct (i,j)
        fvectors(i-halfNeighborhoodSize,j-halfNeighborhoodSize,:) = vector;
    end
end

end

