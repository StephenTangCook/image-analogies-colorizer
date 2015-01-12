function [ min_difference ] = findBestMatchANNwithPreviousLevel( fVectorB, smaller_scale_fVectorB, fVectorBp, smaller_scale_fVectorBp, A, Ap, neighborhood_size, smaller_scale_neighborhood_size, anno, annPts, k, eps )
%findBestMatchANNwithPreviousLevel Find the pixel in A/Ap that best matches the feature
%vector given using ANN.
%   Detailed explanation goes here

%ANN match
Afvectors = A.fvectors;

full_neighborhood = neighborhood_size*neighborhood_size;
halfNeighborhoodSize = floor(full_neighborhood/2);

%Smaller scale
%smaller_scale_full_neighborhood = smaller_scale_neighborhood_size*smaller_scale_neighborhood_size;

%Gaussian weights
gauss_matrix = fspecial('gaussian', neighborhood_size);
gauss_weights = reshape(gauss_matrix.',1,[]); % single vector form
partial_gauss_weights = gauss_weights(1, 1:halfNeighborhoodSize);
concatGaussWeights = [gauss_weights partial_gauss_weights];
%square root of the gaussian weights
concatGaussWeightsSR = sqrt(concatGaussWeights);

%Both smaller_B and smaller_Bp use full neighborhoods
gauss_matrix = fspecial('gaussian', smaller_scale_neighborhood_size);
gauss_weights = reshape(gauss_matrix.',1,[]); % single vector form
smaller_scale_concatGaussWeights = [gauss_weights gauss_weights];
%square root of the gaussian weights
smaller_scale_concatGaussWeightsSR = sqrt(smaller_scale_concatGaussWeights);

concatGaussWeightsSR = [concatGaussWeightsSR smaller_scale_concatGaussWeightsSR];

%% Use ANN to find nearest neighbor of this B + Bp + small_B + small_Bp fvector
%numRowsA = size(Afvectors,1);
numColsA = size(Afvectors,2);
min_difference.norm = intmax; % start with max integer value

pt = [fVectorB fVectorBp smaller_scale_fVectorB smaller_scale_fVectorBp];
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

