function [ annMatrix ] = createANNmatrix( Afvectors, Apfvectors, neighborhood_size )
%createANNmatrix Creates matrix of dxN ANN points (N points of
%d-dimensions). Combines fvectors of A with partial fvectors of Ap
%   Detailed explanation goes here

%% Calculate dimensions
numRows = size(Afvectors,1);
numCols = size(Afvectors,2);
numPixels = numRows * numCols;
full_neighborhood = neighborhood_size*neighborhood_size;
halfNeighborhoodSize = floor(full_neighborhood/2);

%% Compute Gaussian weights (for each neighborhood)
gauss_matrix = fspecial('gaussian', neighborhood_size);
gauss_weights = reshape(gauss_matrix.',1,[]); % single vector form
partial_gauss_weights = gauss_weights(1, 1:halfNeighborhoodSize);
concatGaussWeights = [gauss_weights partial_gauss_weights];
%square root of the gaussian weights
concatGaussWeightsSR = sqrt(concatGaussWeights);

%Initially Nxd matrix, will transpose later
%A+Ap
total_vector_length = full_neighborhood + halfNeighborhoodSize;
annMatrix = zeros(numPixels,total_vector_length);

%% Get neighborhood features for each pixel, weight with sqrt Gaussian
px = 1;
for i=1:numRows
    for j=1:numCols
        %Get fvector from A
        fvector = Afvectors(i,j,:);
        a(1,:) = fvector;

        %Get fvector from Ap
        fvector = Apfvectors(i,j,:);
        ap(1,:) = fvector;
        
        %Combine fvectors horizontally, weight with sqrt of Gauss
        a_ap = [a ap].*concatGaussWeightsSR;
        
        %Add fvector (point) to matrix
        annMatrix(px,:) = a_ap;
        px = px + 1;
    end
end

annMatrix = annMatrix';

end

