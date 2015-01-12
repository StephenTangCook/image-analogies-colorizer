function [ min_difference ] = findBestMatchBrute( fVectorB, fVectorBp, A , Ap, neighborhood_size )
%findBestMatchBrute Find the pixel in A/Ap that best matches the feature
%vector using manual brute force.
%   Detailed explanation goes here

%% Create a mask for incomparable/invalid spots that have a value of -1
%Creates a mask where there is a 1 for all elements not -1, and 0 for all
%   elements with -1.
mask = fVectorBp ~= -1;

%% Arrange Gaussian weights
%mask.*AVector
%Subtract, square, Gauss weight
gauss_matrix = fspecial('gaussian', neighborhood_size);
gauss_weights = reshape(gauss_matrix.',1,[]); % single vector form
partial_vector_len = size(fVectorBp, 2);
partial_gauss_weights = gauss_weights(1, 1:partial_vector_len);

%Concatenate complete KxK neighborhood with partial neighborhood
fVectorBpMasked = fVectorBp.*mask;
concatFVectorBBp = [fVectorB fVectorBpMasked];
concatGaussWeights = [gauss_weights partial_gauss_weights];


%% Iterate through all pixels' neighborhoods in A/Ap to match the fvector
numRowsA = size(A.features,1);
numColsA = size(A.features,2);
min_difference.norm = intmax; % start with max integer value
for i=1:numRowsA
    for j=1:numColsA
        a = A.fvectors(i,j,:);
        fVectorA(1,:) = a(:,:,:);
        
        ap = Ap.fvectors(i,j,:); %partial
        fVectorAp(1,:) = ap(:,:,:);
        %mask the partial invalid neighborhood
        fVectorAp = fVectorAp.*mask; %zeros out the elements corresponding to -1
        concatFVectorAAp = [fVectorA fVectorAp];
        
        %Find the difference (norm) between fvectors
        norm = featureVectorDifference(concatFVectorAAp, concatFVectorBBp, concatGaussWeights);
        if norm < min_difference.norm
            min_difference.norm = norm;
            min_difference.i = i;
            min_difference.j = j;
        end
        
    end
end

end

