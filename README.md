# BifLib
BifLib is a MATLAB library for generating Basic Image Features (BIFs) from images.

## Features
Generate map of BIFs from a **greyscale** image using `bifs = mtBifs(inputImage, blurWidth, flatnessThreshold)`

Display the map of BIFs using `mtBifShow(bifs)`

Run tests to verify the output of mtBifs for canonical features for each BIF class using one of:

`mtBifs_test(1);` to print a test report in the Matlab command window

`[testOutcomes, testOutcomeDetails] = mtBifs_test(0);` to save the test outcomes 
and outcome messages for further processing with no printed output.


For further information on any of the above functions type: `help <functionName>` at the Matlab command line

## Introduction to BIFs
BIFs are a classification of local image structure into seven different classes on the basis of approximate local symmetry. 
The seven classes are:

1 = _flat_ (pink)

2 = _gradient_ (grey)

3 = _dark blob_ (black)

4 = _light blob_ (white)

5 = _dark line_ (blue)

6 = _light line_ (yellow)

7 = _saddle_ (green)

For a detailed explanation of BIFs, see [Using Basic Image Features for Texture Classification](http://dx.doi.org/10.1007/s11263-009-0315-0) 
by Mike Crosier and Lewis D. Griffin. If you don't have access to the published journal paper, see the free 
[author version](http://discovery.ucl.ac.uk/74308/) from UCL's institutional repository.

## Citation
O'Reilly, Martin (2016): BifLib (v1.0). figshare. https://dx.doi.org/10.6084/m9.figshare.3749094.v1