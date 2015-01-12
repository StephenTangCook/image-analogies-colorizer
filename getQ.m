function [ Q ] = getQ( r, g, b )
%getQ Get Q of YIQ color space.
%   Detailed explanation goes here

% Q of YIQ color
%0.212 * c[0] - 0.523 * c[1] + 0.311 * c[2];
Q = 0.212 * r - 0.523 * g + 0.311 * b;
end

