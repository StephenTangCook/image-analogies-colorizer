function [ smoothed ] = imageSmoother( img, showSmoothedResults )
%imageSmoother Smooth incorrect parts of the analogies (eg. specks).
%   imageSmoother(imread('results/piano1.3NN.COLORIZED.png'))

% showSmoothedResults = 0;
numRows = size(img,1);
numCols = size(img,2);

% smoothed is initially the same
img = im2double(img);
smoothed = img;

% Calculate luminance and standard deviation
luminance = convertToLuminance(img);
sd = std2(luminance);
detect_threshold = sd/1.7; %when is a pixel too bright/dark compared to neighbors?
change_threshold = sd/2.8; %what lum should the pixel be brought to?
sd_change = sd/4;

for i = 2:numRows-1
    for j = 2:numCols-1
        Y = luminance(i,j);
        %Use top,left,right,bottom pixels for comparison
        neighbors = [ ...
%                     luminance(i-1,j-1:j+1), ...
%                     luminance(i+1,j-1:j+1), ...
                    luminance(i+1,j), ...
                    luminance(i-1,j) ...
                    luminance(i,j-1), ...
                    luminance(i,j+1) ...
                    ];
        %Calculate neighbor average
        neighbor_avg = mean2(neighbors);
        %If this pixel is over a threshold, change it
        if Y > neighbor_avg + detect_threshold
            while Y > neighbor_avg + change_threshold
                Y = Y - sd_change;
            end
        elseif Y < neighbor_avg - detect_threshold
            while Y < neighbor_avg - change_threshold
                Y = Y + sd_change;
            end
        else
            continue
        end
        
        %Set new Y
        luminance(i,j) = Y;
        channels = img(i,j,:);
        r = channels(:,:,1);
        g = channels(:,:,2);
        b = channels(:,:,3);
        
        I = getI(r, g, b);
        Q = getQ(r, g, b);
        RGB = convertYIQtoRGB(Y, I, Q);
        newR = RGB(1);
        newG = RGB(2);
        newB = RGB(3);
        
        smoothed(i,j,:) = [newR newG newB];
    end
end

%Show final colorized image result
if showSmoothedResults
    figure,
    subplot(1,2,1);
    imshow(img);
    title('Original image');
    subplot(1,2,2);
    imshow(smoothed);
    title('Smoothed image');
end

end

