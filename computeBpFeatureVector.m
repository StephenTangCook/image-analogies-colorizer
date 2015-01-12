function [ fvector ] = computeBpFeatureVector( Bpfeatures, neighborhood_size, i, j )
%computeFeatureVectors Computes the partial feature vector for a pixel in
%Bp
%   This is for a partial KxK neighborhood.

%% Compute vector
vectorSize = floor((neighborhood_size * neighborhood_size)/2);
halfNeighborhoodSize = floor(neighborhood_size/2);

%Each neighborhood pixel is numbered starting top-left. For example 3x3:
%1 2 3
%4 

% Get the previously synthesized L-shaped neighborhood
neighborhood = ...
        Bpfeatures(i-halfNeighborhoodSize:i+halfNeighborhoodSize, ...
        j-halfNeighborhoodSize:j+halfNeighborhoodSize);
%Convert this top-left KxK neighborhood into a horizontal vector
vector = reshape(neighborhood.',1,[]);

%Remove non-synthesized pixels
fvector = vector(1,1:vectorSize);


end

