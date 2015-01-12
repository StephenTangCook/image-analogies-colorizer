function [ rgb ] = convertYIQtoRGB( Y, I, Q )
%convertYIQtoRGB Convert RGB to YIQ color space.
%   Detailed explanation goes here

r = Y + 0.956*I + 0.621*Q;
g = Y - 0.272*I - 0.647*Q;
b = Y - 1.105*I + 1.702*Q;
rgb = [r g b];

end

