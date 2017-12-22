Automatic Image Colorization Using Image Analogies


This framework takes a grayscale image and colorizes it.
Given that you have an image dataset (e.g. Caltech 101) in the 'dataset' directory where this file is executed, colorizeImage.m can run out of the box with the following commands:
	ann_class_compile;
	colorizeImage(imagePath, train, testMode, numExemplars, levels);

where imagePath is a filepath to the grayscale image, train is a boolean where true will train an entirely new classifier on the dataset, testMode is a boolean where true means the input image is already in color, numExemplars is the number of exemplars to use, and levels is the number of levels to use during multi-resolution synthesis in image analogies.

The following would be an example command to colorize 'GrayCity.jpg' using the existing classifier, 2 exemplars, and 3 levels in image analogies:
	colorizeImage('images/GrayCity.jpg', 0, 0, 2, 3);


The completed project source code is hosted on GitHub:
https://github.com/Neji107/image_colorization


The historical development source code and some intermediate results can be seen on BitBucket:
https://bitbucket.org/Neji107/image_analogies
