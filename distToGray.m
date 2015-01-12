function [ dist ] = distToGray( r, g, b )
%distToGray Summary of this function goes here
%   Detailed explanation goes here

dist = abs(r-b) + abs(r-g) + abs(b-g);

end

