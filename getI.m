function [ I ] = getI( r, g, b )
%getI Get I of YIQ space.
%   Detailed explanation goes here

% I of YIQ color
% 0.596 * c[0] - 0.274 * c[1] - 0.322 * c[2];
I = 0.596 * r - 0.274 * g - 0.322 * b;
end

