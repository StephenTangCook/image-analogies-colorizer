function [ categoryClassifier ] = trainClassifier( pathFolder, percentImagesForTraining, evaluateSets, saveClassifier )
%trainClassifier Train an image classifier with a given dataset.

%% Get all folders in dataset
%Source: http://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
classifierFileName = 'classifier.mat';

fprintf('Getting all folders (categories) in dataset...\n');
d = dir(pathFolder);
isub = [d(:).isdir]; % returns logical vector
dirNames = {d(isub).name}';
%remove . and .. and .DS_Store
dirNames(ismember(dirNames,{'.','..','.DS_Store','Thumbs.db'})) = [];

%% Use each folder as a category
fprintf('Converting folders to image sets...\n');
imgSets = [];
for i = 1:size(dirNames,1)
    category = dirNames(i,1);
    imgSets = [ imgSets, imageSet(fullfile(pathFolder, category{1})) ];
end

fprintf('All categories:');
disp({imgSets.Description});

%% Get training sets for each category
fprintf('Getting training sets for each category...\n');
minSetCount = min([imgSets.Count]); % determine the smallest amount of images in a category

% Use partition method to trim the set so they are all same size
imgSets = partition(imgSets, minSetCount, 'randomize');

% Each set now has exactly the same number of images.
fprintf('Using %d images for each category.\n', minSetCount);

%% Train classifier with training set
trainingSetSize = int32(minSetCount*percentImagesForTraining);
fprintf('The training set consists of %d images (%4.2f percent) of each category.\n',...
    trainingSetSize, percentImagesForTraining*100);

%Partition into training set
[trainingSets, validationSets] = partition(imgSets, percentImagesForTraining, 'randomize');

%Use bagOfFeatures function, which:
%   1. extracts SURF features from all images in all image categories
%   2. constructs the visual vocabulary by reducing the number of features through quantization of feature space using K-means clustering
bag = bagOfFeatures(trainingSets);

%Classifier training for multiclass linear SVM classifier
categoryClassifier = trainImageCategoryClassifier(trainingSets, bag);

%Save trained classifier to file
if saveClassifier
    save(classifierFileName, 'categoryClassifier');
end

%% Evaluation of classifier
if evaluateSets
    fprintf('Evaluation of classifier on training set (should be very accurate):\n');
    confMatrix_t = evaluate(categoryClassifier, trainingSets);
    fprintf('Evaluation of classifier on validation set:\n');
    confMatrix_v = evaluate(categoryClassifier, validationSets);
end

end
