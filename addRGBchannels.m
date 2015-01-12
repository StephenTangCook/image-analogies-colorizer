function [ rgbChannelImg ] = addRGBchannels( rawImg )
%addRGBchannels Adds identical RGB channels if grayscale image
%   Detailed explanation goes here

%Does this picture have three RGB channels?
if size(rawImg,3) == 1
    %This is a grayscale image, add identical GB channels
    rgbChannelImg = rawImg;
    rgbChannelImg(:,:,2) = rawImg(:,:,1);
    rgbChannelImg(:,:,3) = rawImg(:,:,1);
else
    %Do nothing
    rgbChannelImg = rawImg;
end

end

