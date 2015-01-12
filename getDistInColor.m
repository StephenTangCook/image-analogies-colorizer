function [ dist ] = getDistInColor( imgA, imgB )
%getDistInColor Calculate the difference between two pictures in terms of
%their chrominance.
%   0% image colors identical
%   1% slightly off color
%   5% sections miscolored
%   10% significant deviation
%   15% catastrophic failure (e.g. inverse coloring)

multiplier = 5;
% With multipler = 5:
%   0% image colors identical
%   5% slightly off color
%   20% sections miscolored
%   50% significant deviation
%   75%+ catastrophic failure (e.g. inverse coloring)

%Read in, if not already
if ischar(imgA)
    imgA = imread(imgA);
end
if ischar(imgB)
    imgB = imread(imgB);
end

imgA=addRGBchannels(im2double(imgA));
imgB=addRGBchannels(im2double(imgB));

numRows = size(imgA,1);
numCols = size(imgA,2);

%Assumes the same size
aR = imgA(:,:,1);
aG = imgA(:,:,2);
aB = imgA(:,:,3);

bR = imgB(:,:,1);
bG = imgB(:,:,2);
bB = imgB(:,:,3);

% aY = getY(aR,aG,aB);
aI = getI(aR,aG,aB);
aQ = getQ(aR,aG,aB);

% bY = getY(aR,aG,aB);
bI = getI(bR,bG,bB);
bQ = getQ(bR,bG,bB);

diffMatrix = abs(aI-bI) + abs(aQ-bQ);
diffSum = sum(diffMatrix(:));

%Calculate max dist possible
%I parameter has the range [-0.523,0.523], and the Q parameter has the range [-0.596,0.596]
% aIdistToMax = abs(aI - 0.523*ones(numRows,numCols));
% aQdistToMax = abs(aQ - 0.596*ones(numRows,numCols));
% bIdistToMax = abs(bI - 0.523*ones(numRows,numCols));
% bQdistToMax = abs(bQ - 0.596*ones(numRows,numCols));
% 
% aIdistToMin = abs(aI - -0.523*ones(numRows,numCols));
% aQdistToMin = abs(aQ - -0.596*ones(numRows,numCols));
% bIdistToMin = abs(bI - -0.523*ones(numRows,numCols));
% bQdistToMin = abs(bQ - -0.596*ones(numRows,numCols));
% 
% 
% aIMaxDiff = bsxfun(@max, aIdistToMax, aIdistToMin);
% aQMaxDiff = bsxfun(@max, aQdistToMax, aQdistToMin);
% bIMaxDiff = bsxfun(@max, bIdistToMax, bIdistToMin);
% bQMaxDiff = bsxfun(@max, bQdistToMax, bQdistToMin);
% totalMaxDiff = aMaxDiff+bMaxDiff;
% totalMaxDiff = sum(totalMaxDiff(:));

maxDiff = 2*numRows*numCols; %I1-I2=1.0, Q1-Q2=1.0

dist = diffSum/maxDiff *100 * multiplier;
% dist = diffSum/totalMaxDiff *100;

end

