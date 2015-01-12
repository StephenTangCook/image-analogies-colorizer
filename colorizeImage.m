function [ final_colorization ] = colorizeImage( inputImagePath, trainNewClassifier, testingMode, numExemplarsToUse, levels, exemplarImagePath )
%colorizeImage Main for automatic colorization using image analogies
%   Example command: Colorize mountain5.jpg, do not train new classifier,
%   already in color, 2 exemplars, 3 levels for image analogies:
%   colorizeImage('images/mountain5.jpg', 0, 1, 2, 3);
%
% Expects the following layout:
% Dataset:
%   dataset/
% Results (where it saves colorized image):
%   results/
% ANN library:
%   @ann/
%   ann_tests/
% Classifier (pre-trained:
%   ./classifier.mat

%% Parameters
avg_lum = 1; %do both lum and non-lum remapping?
useNNforExemplar = 1; %use NN to search for exemplars or random?
%numExemplarsToUse = 2; %how many exemplar images
comboType = 'vibrance';
showSmoothedResults = 0;
showComboComparison = 1;

brute_force = 0;
neighborhood_size = 5;

maxSubsetSize = 25; %max subset size of images to search through for NN
minSubsetSize = 10; %min subset size of images to search through for NN
percentToSearchForExemplar = 0.25; %how much of the category to search for NN
displayExemplarChosen = 1; %display all the exemplar(s) chosen for analogies
% classifierFileName = 'classifier.mat'; %name of the classifier to load, if not training one
classifierFileName = 'classifierFULL.mat';

%Start timer
tic

%% Where to save the results
resultsFolder = 'results';
imgNameCell = regexp(inputImagePath, '(/+|\\+)(.*)\.', 'tokens');
imgName = imgNameCell{1}{2};

%numExemplars(NN | rand)
additional_str = '.';
if useNNforExemplar
    additional_str = strcat(additional_str, num2str(numExemplarsToUse), 'NN');
else
    additional_str = strcat(additional_str, num2str(numExemplarsToUse), 'rand');
end

resultsFilePath = fullfile(resultsFolder,strcat(imgName,additional_str,'.COLORIZED.png'));
resultsFigPathPrefix = fullfile(resultsFolder,strcat(imgName,additional_str));

if exist(resultsFilePath, 'file')
    additional_str = strcat(additional_str, '.');
end

while exist(resultsFilePath, 'file')
    % File already exists. Rename.
    additional_str = strcat(additional_str, '0');
    resultsFilePath = fullfile(resultsFolder,strcat(imgName,additional_str,'.COLORIZED.png'));
    
    resultsFigPathPrefix = fullfile(resultsFolder,strcat(imgName,additional_str));
end

%% Args and defaults
switch nargin
    case 6
        useProvidedExemplar = 1;
    case 5
        useProvidedExemplar = 0;
        inputFileName = inputImagePath;
    case 4
        useProvidedExemplar = 0;
        inputFileName = inputImagePath;
        levels = 1;
    case 3
        useProvidedExemplar = 0;
        inputFileName = inputImagePath;
        numExemplarsToUse = 2;
        levels = 1;
    case 2
        inputFileName = inputImagePath;
        useProvidedExemplar = 0;
        testingMode = 0;
        numExemplarsToUse = 2;
        levels = 1;
    case 1
        inputFileName = inputImagePath;
        trainNewClassifier = 0;
        useProvidedExemplar = 0;
        testingMode = 0;
        numExemplarsToUse = 2;
        levels = 1;
    otherwise % no args
        imagesRootFolder = 'images';
        inputFile = 'obama.jpg';
        inputFileName = fullfile(imagesRootFolder, inputFile);
        trainNewClassifier = 0;
        useProvidedExemplar = 0;
        testingMode = 0;
        numExemplarsToUse = 2;
        levels = 1;
end

%% Read in input file to colorize
inputImage = imread(inputFileName);
fprintf('Colorizing input image: %s.\n', inputFileName);

%If in testing mode, convert the input image to grayscale (already in
%color)
if testingMode
    fprintf('Testing Mode: Converting input image to grayscale.\n');
    inputImage = rgb2gray(inputImage);
end

%% Train the image classifier
pathFolder = 'dataset'; %location of image dataset to train on
percentImagesForTraining = 0.4; %how many pictures in each folder/category to use
evaluateSets = 0; %do an evaluation of the classifier?
saveClassifier = 1; %save the classifier to a file?
if trainNewClassifier
    fprintf('Training new classifier.\n');
    categoryClassifier = trainClassifier(pathFolder, percentImagesForTraining, evaluateSets, saveClassifier);
else
    fprintf('Skipping training. Loading classifier from file: %s.\n', classifierFileName);
    load(classifierFileName);
end

%% Classify the input image
labelInfo = getImageClassification(categoryClassifier, inputFileName);
label = labelInfo.label{1};
confidence = abs(labelInfo.confidence)*100;
fprintf('Input image classified as "%s" with %4.2f%% confidence.\n', label, confidence);

%% Pick exemplar image(s) from the same category
if useProvidedExemplar
    all_exemplars_color{1} = imread(exemplarImagePath);
else
    fprintf('Picking %d exemplar images.\n', numExemplarsToUse);
    %Get all images in that folder category
    %Remove subdirectories
    datasetRootFolder = 'dataset';
    all_exemplars_color = cell(1,numExemplarsToUse);

    %Choose image exemplar(s) to use
    if useNNforExemplar
        %Find the nearest neighbors within the image category
        pathToImgSet = fullfile(datasetRootFolder,label);
        NN = rankNearestNeighbors(pathToImgSet, inputImage, percentToSearchForExemplar, maxSubsetSize, minSubsetSize);
        exemplarsToUse = NN.files(1:numExemplarsToUse);
        for i = 1:numExemplarsToUse
            chosenFileName = exemplarsToUse(i);
            chosenFileName = fullfile(datasetRootFolder,label,chosenFileName{1});
            fprintf('Using exemplar image: %s.\n', chosenFileName);
            all_exemplars_color{i} = imread(chosenFileName);
        end
    else
        %Pick exemplars at random
        %Source: http://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
        d = dir(fullfile(datasetRootFolder,label));
        isub = ~[d(:).isdir]; % returns logical vector
        files = {d(isub).name}';
        %remove . and .. and .DS_Store
        files(ismember(files,{'.','..','.DS_Store','Thumbs.db'})) = [];
        for i = 1:numExemplarsToUse
            %Pick a random one
            idx = randi(size(files,1));
            fileChosen = files(idx);
            chosenFileName = fullfile(datasetRootFolder,label,fileChosen);
            chosenFileName = chosenFileName{1};
            fprintf('Using exemplar image: %s.\n', chosenFileName);
            all_exemplars_color{i} = imread(chosenFileName);
        end
    end
end

clearvars NN;

%Display the exemplars
if displayExemplarChosen
    figure;
    %Input image
    subplot(2,numExemplarsToUse,1);
    imshow(inputImage);
    title(strcat('Input image (labeled in "', label, '" category)'));
    
    %Exemplars
    for i = 1:numExemplarsToUse
        subplot(2,numExemplarsToUse,i+numExemplarsToUse);
        imshow(all_exemplars_color{i});
        if useNNforExemplar
            title(strcat('Exemplar #', num2str(i),' (NN)'));
        else
            title(strcat('Exemplar #', num2str(i),' (rand)'));
        end
    end
    
    %Save figure to file
    savefig(strcat(resultsFigPathPrefix,'.exemplars.fig'));
end

%% Image Analogies
%Resulting colorizations from analogies
all_analogy_colorizations = cell(1,numExemplarsToUse);

%Do an image analogy for each exemplar
for i = 1:numExemplarsToUse
    %% Prepare exemplar image for image analogies
    exemplar_color = all_exemplars_color{i};
    %Convert exemplar image Ap to grayscale for A
    exemplar_grayscale = rgb2gray(exemplar_color); % will fail here if exemplar is already grayscale!

    %% Image analogies call
    fprintf('\nBeginning image analogies for exemplar #%d of %d...\n', i, numExemplarsToUse);
    
    %Get luminance remapped and non-remapped version, average both
    if avg_lum
        analogy_fig_name1 = strcat(resultsFigPathPrefix, '.', num2str(i),'lum');
        analogy_fig_name2 = strcat(resultsFigPathPrefix, '.', num2str(i),'nolum');
        colorized_image1 = analogy( exemplar_grayscale, exemplar_color, inputImage, neighborhood_size, brute_force, 1, analogy_fig_name1, levels);
        colorized_image2 = analogy( exemplar_grayscale, exemplar_color, inputImage, neighborhood_size, brute_force, 0, analogy_fig_name2, levels);

        %Average the two
        fprintf('Averaging luminance remapping and non-remapped colorzations.\n');
        combined = cat(4, colorized_image1, colorized_image2);
        avg_lum_image = mean(combined, 4); %average lum with non-lum remapping

        all_analogy_colorizations{i} = avg_lum_image;
        clearvars colorized_image1 colorized_image2 combined;
    else
        analogy_fig_name1 = strcat(resultsFigPathPrefix, '.', num2str(i),'lum');
        %Only do once with luminance re-mapped
        all_analogy_colorizations{i} = analogy( exemplar_grayscale, exemplar_color, inputImage, neighborhood_size, brute_force, 1, analogy_fig_name1);
    end
end

%% Display analogy colorizations for exemplars
if displayExemplarChosen
    figure;
    %Input image
    subplot(2,numExemplarsToUse,1);
    imshow(inputImage);
    title('Input image (grayscale)');
    
    %Exemplar analogies
    for i = 1:numExemplarsToUse
        subplot(2,numExemplarsToUse,i+numExemplarsToUse);
        imshow(all_analogy_colorizations{i});
        if useNNforExemplar
            title(strcat('Colorization #', num2str(i),' (NN)'));
        else
            title(strcat('Colorization #', num2str(i),' (rand)'));
        end
    end
    
    %Save figure to file
    savefig(strcat(resultsFigPathPrefix,'.colorizations.fig'));
end

%% Combine all analogy colorizations
%Combine all colorizations
fprintf('\nCombining all final analogy colorization(s)...\n');
final_colorization = combineColorizations(all_analogy_colorizations, 'vibrance');
final_colorization2 = combineColorizations(all_analogy_colorizations, 'average');

if showComboComparison
    %Compare combination strategies
    figure, subplot(1,2,1);
    imshow(final_colorization);
    title(comboType);
    subplot(1,2,2);
    imshow(final_colorization2);
    title('average');
end

%% Smooth the final image (remove specks)
final_colorization = imageSmoother(final_colorization, showSmoothedResults);

%% Show final results
%Show final colorized image result
figure,
subplot(1,2,1);
imshow(inputImage);
title('Original image');
subplot(1,2,2);
imshow(final_colorization);
title(strcat('Final colorized result (', comboType, ' combo of ', num2str(numExemplarsToUse), ' colorizations)'));

%Save figure to file
savefig(strcat(resultsFigPathPrefix,'.finalColor.fig'));

%Write final colorized image to file
imwrite(final_colorization, resultsFilePath, 'png');

%End timer, record runtime
time = toc;
fid = fopen('runtimes.txt', 'at');
fprintf(fid, '%f\n', time);
fclose(fid);

end