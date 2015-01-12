function [ label ] = getImageClassification( categoryClassifier, fileName )
%getImageClassification Classify a given image into a category.

img = imread(fileName);
[labelIdx, scores] = predict(categoryClassifier, img);

% Display the string label
label.label = categoryClassifier.Labels(labelIdx);
label.confidence = scores(labelIdx);


end