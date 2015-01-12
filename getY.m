function [ Y ] = getY( r,g,b )
%getY Get Y of YIQ color space.
%   Detailed explanation goes here

% 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2];
Y = 0.299 * r + 0.587 * g + 0.114 * b;

end

