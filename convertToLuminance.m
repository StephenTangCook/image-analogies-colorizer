function [ luminance ] = convertToLuminance( rawImg )
%convertToLuminosity Converts the raw image with RGB values to luminance
%values
%   Y = 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2];

red = rawImg(:,:,1);
green = rawImg(:,:,2);
blue = rawImg(:,:,3);
luminance = 0.299*red + 0.587*green + 0.114*blue;

end

