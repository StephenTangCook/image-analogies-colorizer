function [ RGB ] = convertYIQtoRGB2( Y, I, Q )
%convertYIQtoRGB Convert RGB to YIQ color space for matrices.
%   Detailed explanation goes here

R = Y + 0.956*I + 0.621*Q;
G = Y - 0.272*I - 0.647*Q;
B = Y - 1.105*I + 1.702*Q;
RGB(:,:,1) = R;
RGB(:,:,2) = G;
RGB(:,:,3) = B;

end

