function [ min_difference ] = findBestMatchANN( fVectorB, fVectorBp, A, Ap, neighborhood_size, anno, annPts, k, eps )
%findBestMatchANN Find the pixel in A/Ap that best matches the feature
%vector given using ANN.
%   Detailed explanation goes here

%If at the edge of Bp, use brute force match
% if any(fVectorBp == -1)
%     min_difference = findBestMatchBrute(fVectorB, fVectorBp, A , Ap, neighborhood_size);
%     return;
% end

%ANN match
Afvectors = A.fvectors;

full_neighborhood = neighborhood_size*neighborhood_size;
halfNeighborhoodSize = floor(full_neighborhood/2);

%Gaussian weights
gauss_matrix = fspecial('gaussian', neighborhood_size);
gauss_weights = reshape(gauss_matrix.',1,[]); % single vector form
partial_gauss_weights = gauss_weights(1, 1:halfNeighborhoodSize);
concatGaussWeights = [gauss_weights partial_gauss_weights];
%square root of the gaussian weights
concatGaussWeightsSR = sqrt(concatGaussWeights);

%% Use ANN to find nearest neighbor of this B+Bp fvector
%numRowsA = size(Afvectors,1);
numColsA = size(Afvectors,2);
min_difference.norm = intmax; % start with max integer value

pt = [fVectorB fVectorBp];
pt = pt.*concatGaussWeightsSR;
pt = pt';
[idx dst] = ksearch(anno, pt, k, eps);

% nearest_neighbor = annPts(idx);
rowA = ceil(double(idx)/numColsA);
colA = idx - ((rowA-1)*numColsA);

min_difference.norm = dst;
min_difference.i = rowA;
min_difference.j = colA;

end

