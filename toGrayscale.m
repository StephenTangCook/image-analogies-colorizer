function [] = toGrayscale( imgName )
%toGrayscale Convert and save a given image to grayscale.
%   Detailed explanation goes here

I = rgb2gray(imread(imgName));
imwrite(I,strcat(imgName,'.gs.bmp'));

end

