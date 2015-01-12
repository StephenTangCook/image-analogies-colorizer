function [ ] = evaluateResults( imagesDir, resultsDir )
%evaluateResults Summary of this function goes here
%   Detailed explanation goes here

%Write to file
writeFileName = 'distances.txt';
writeFileName2 = 'distances-named.txt';
fid = fopen(writeFileName, 'w');
fid2 = fopen(writeFileName2, 'w');

%Get all image files in that folder
%Source: http://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
d = dir(resultsDir);
isub = ~[d(:).isdir]; % returns logical vector
resultImages = {d(isub).name}';
%remove . and .. and .DS_Store
resultImages(ismember(resultImages,{'.','..','.DS_Store','Thumbs.db'})) = [];

% numResults = size(resultImages,1);
i = 1;
while i <= size(resultImages,1)
    fileName = resultImages(i);
    fileName = fileName{1};
    matchStr = regexpi(fileName, '.fig', 'match');
    if size(matchStr,1)> 0 %matched .fig
        resultImages(i) = [];
        i = i - 1;
    end
    i = i + 1;
end

d = dir(imagesDir);
isub = ~[d(:).isdir]; % returns logical vector
originalImages = {d(isub).name}';
originalImages(ismember(originalImages,{'.','..','.DS_Store','Thumbs.db'})) = [];

% numOriginals = size(originalImages,1);
i = 1;
while i <= size(originalImages,1)
    fileName = originalImages(i);
    fileName = fileName{1};
    matchStr = regexpi(fileName, '(.jpg)|(.jpeg)', 'match');
    if size(matchStr,1) == 0 % does not match .jpg
        originalImages(i) = [];
        i = i - 1;
    end
    i = i + 1;
end


%Go through all results and compare with original
for i=1:size(resultImages,1)
    fileName = resultImages(i);
    fileName = fileName{1};
    matchStr = regexpi(fileName, '(\w+)\.', 'tokens');
    imgPrefix = matchStr{1};
    imgPrefix = imgPrefix{1};
    
    originalName = strcat(imgPrefix, '.jpg');
    fullOriginalImgPath = fullfile(imagesDir, originalName);
    fullResultsImgPath = fullfile(resultsDir, fileName);
    
    try
        imgA = imread(fullOriginalImgPath);
        imgB = imread(fullResultsImgPath);
    catch err
        %fprintf('SKIP\n');
        continue;
    end
    
    %Compare with original, write to file
    if size(imgA,1) ~= size(imgB,1) || size(imgA,2) ~= size(imgB,2)
        fprintf('Image dimensions do not match. Skipping: %s, %s\n', fullOriginalImgPath, fullResultsImgPath);
    else
        dist = getDistInColor(imgA, imgB);
        fprintf('Evaluating %s and %s\n', fullOriginalImgPath, fullResultsImgPath);
        fprintf('\tColor Distance = %4.2f\n', dist);
        
        %Write to file2
        fprintf(fid2, '%s \n%s\n', fullOriginalImgPath, fullResultsImgPath);
        fprintf(fid2, '\tColor Distance = %4.2f\n', dist);
        
        if i == size(resultImages,1)%last line
            fprintf(fid, '%f', dist); % no newline
        else
            fprintf(fid, '%f\n', dist);
        end
    end
end

fprintf('Done.\nDistances stored in %s.\n', writeFileName);

%Close file
fclose(fid);
fclose(fid2);

end

