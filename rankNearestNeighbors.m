function [ NN ] = rankNearestNeighbors( pathToImgSet, inputImg, percentToSearch, maxSubsetSize, minSubsetSize)
%rankNearestNeighbors Find the closest image(s)
%   Detailed explanation goes here

if nargin == 2
    percentToSearch = 0.20;
    maxSubsetSize = 20;
    minSubsetSize = 10;
end

fprintf('\nFinding nearest neighbor for exemplar image:\n');
print_progress = 1;
percent_increase_print = 0.10;

%% Get a subset for comparison
%Get all image files in that folder
%Source: http://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
d = dir(pathToImgSet);
isub = ~[d(:).isdir]; % returns logical vector
files = {d(isub).name}';
%remove . and .. and .DS_Store
files(ismember(files,{'.','..','.DS_Store','Thumbs.db'})) = [];

%Choose random subset of those images to search through
numFiles = size(files,1);
randomIdx = randperm(numFiles);
files(randomIdx) = files; %permute file names randomly
subset = uint32(percentToSearch*numFiles);

%Hard maximum/minimum subset size
if subset > maxSubsetSize
    subset = maxSubsetSize;
end
if subset < minSubsetSize
    subset = minSubsetSize;
end

files = files(1:subset, :); %Remove portion
fprintf('Ranking images of random subset (%d of %d images)...\n', subset, numFiles);

%% Compare each against the input image
%Add RGB channels to the input image
inputImg = addRGBchannels(inputImg);

numRows = size(inputImg,1);
numCols = size(inputImg,2);

%Measure each image against the input
numFiles = size(files,1);
NNscores = zeros(numFiles,2);
count = 0;
prev_percent = 0;
for i = 1:numFiles
    f = files(i);
    currentImg = imread(fullfile(pathToImgSet,f{1}));
    currentImg = addRGBchannels(currentImg);
    %Resize to be same dimension as input image
    currentImg = imresize(currentImg, [numRows numCols]);
    NNscores(i,1) = ssim(currentImg, inputImg); %use ssim for comparison
    NNscores(i,2) = i;
    
    %Print progress
    count = count + 1;
    percent = (count/numFiles);
    %fprintf('File #%d of %d\n', count, numFiles);
    if (print_progress) && (percent >= prev_percent + percent_increase_print)
        fprintf('\t%3.2f percent of images ranked...\n', percent*100);
        prev_percent = percent;
    end
end

%% Sort images by descending score
sortedScores = sortrows(NNscores);
sortedScores = flipud(sortedScores); %descending order

sortedFiles = files(sortedScores(:,2));

NN.scores = sortedScores(:,1);
NN.files = sortedFiles;

end

