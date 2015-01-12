function [ AllLevels ] = computeGaussianPyramid( img, levels, showPyramid )
%computeGaussianPyramid Compute different scales of the image for a
%Gaussian pyramid. Used for multiresolution synthesis.
%   Returns all levels in order from coarsest to finest.

if nargin == 2
    showPyramid = 0;
end

%Read in image, if not already
if ischar(img)
    img = imread(img);
end

AllLevels = cell(1,levels);
AllLevels{levels} = img;
smallerScale = img;
for i=2:levels
    smallerScale = impyramid(smallerScale, 'reduce');
    AllLevels{levels-i+1} = smallerScale;
end

if showPyramid
    figure;
    for i=1:levels
        subplot(1,levels,i);
        imshow(AllLevels{i});
        title(strcat('Level', num2str(i)));
    end
end


end

