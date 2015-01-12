function [ combined ] = combineRGBimages( imgA, imgB )
%combineRGBimages Maintains the most vibrant colors of two images when
%combining rGB values.
%   Detailed explanation goes here

% addColors = 0;
% averageColors = 0;

%Read in if not already
if ischar(imgA)
    imgA = im2double(imread(imgA));
end
if ischar(imgB)
    imgB = im2double(imread(imgB));
end

%Assumes they are the same size
numRows = size(imgA,1);
numCols = size(imgA,2);
numImgs = 2;

combined = zeros(numRows, numCols, 3);

%% Matlab version
%RGB from imgA
r1 = imgA(:,:,1);
g1 = imgA(:,:,2);
b1 = imgA(:,:,3);
%RGB from imgB
r2 = imgB(:,:,1);
g2 = imgB(:,:,2);
b2 = imgB(:,:,3);
dist1 = abs(r1-g1)+abs(r1-b1)+abs(g1-b1);
dist2 = abs(r2-g2)+abs(r2-b2)+abs(g2-b2);
totalDist = dist1+dist2;

avgR = (r1+r2)/2;
avgG = (g1+g2)/2;
avgB = (b1+b2)/2;

distToAvgR1 = r1-avgR;
distToAvgG1 = g1-avgG;
distToAvgB1 = b1-avgB;
distToAvgR2 = r2-avgR;
distToAvgG2 = g2-avgG;
distToAvgB2 = b2-avgB;

w1 = dist1./totalDist;
w2 = dist2./totalDist;

w1(isnan(w1)) = 0.5;
w2(isnan(w2)) = 0.5;
                
newR= avgR + w1.*distToAvgR1 + w2.*distToAvgR2;
newG= avgG + w1.*distToAvgG1 + w2.*distToAvgG2;
newB= avgB + w1.*distToAvgB1 + w2.*distToAvgB2;

combined(:,:,1)= newR;
combined(:,:,2)= newG;
combined(:,:,3)= newB;

return

%% Pixel-by-pixel version
% for i=1:numRows
%     for j=1:numCols
%         %RGB from imgA
%         r1 = imgA(i,j,1);
%         g1 = imgA(i,j,2);
%         b1 = imgA(i,j,3);
%         %RGB from imgB
%         r2 = imgB(i,j,1);
%         g2 = imgB(i,j,2);
%         b2 = imgB(i,j,3);
%         
%         if addColors
%             clamp = 1.0;
%             newR = min(r1+r2,clamp);
%             newG = min(g1+g2,clamp);
%             newB = min(b1+b2,clamp);
%             combined(i,j,1)= newR;
%             combined(i,j,2)= newG;
%             combined(i,j,3)= newB;
%         elseif averageColors
%             combined(i,j,1) = (r1+r2)/2;
%             combined(i,j,2) = (g1+g2)/2;
%             combined(i,j,3) = (b1+b2)/2;
%         else
%             %Find each's distance to gray
%             %   diff/dist = abs(r-b)+abs(r-g)+abs(b-g)
%             %   dist = ?
%             %sum = all distances to gray
%             %weight_i = dist to gray /sum
%             dist1 = distToGray(r1,g1,b1);
%             dist2 = distToGray(r2,g2,b2);
%             totalDist = dist1+dist2;
%             if(totalDist == 0.0)
%                 %Both are grayscale, weight equally
%                 w1 = 0.5;
%                 w2 = 0.5;
%             else
%                 w1 = dist1/totalDist;
%                 w2 = dist2/totalDist;
%             end
%             
%             avgR = (r1+r2)/2;
%             avgG = (g1+g2)/2;
%             avgB = (b1+b2)/2;
%             
%             distToAvgR1 = r1-avgR;
%             distToAvgG1 = g1-avgG;
%             distToAvgB1 = b1-avgB;
%             distToAvgR2 = r2-avgR;
%             distToAvgG2 = g2-avgG;
%             distToAvgB2 = b2-avgB;
%             
%             newR= avgR + w1*distToAvgR1 + w2*distToAvgR2;
%             newG= avgG + w1*distToAvgG1 + w2*distToAvgG2;
%             newB= avgB + w1*distToAvgB1 + w2*distToAvgB2;
%             
%             combined(i,j,1)= newR;
%             combined(i,j,2)= newG;
%             combined(i,j,3)= newB;
%         end
%         
%     end
% end

end

