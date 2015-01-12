function [ norm ] = featureVectorDifference( fvectorA, fvectorB, concatGaussWeights )
%featureVectorDifference Calculates L2-norm between two vectors, weighting
%the differences according to their distance from the center pixel
%(Gaussian weights).
%   Detailed explanation goes here

vlength = size(fvectorA, 2);
norm = 0;

for i = 1:vlength
    diff = fvectorA(1,i) - fvectorB(1,i);
    weight = concatGaussWeights(1,i);
    %Square the difference, then weight by Gaussian
    norm = norm + (weight*(diff*diff));
end

end

