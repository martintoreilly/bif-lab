# BifLib
BifLib is a MATLAB library for generating Basic Image Features (BIFs) from images.

## Features
Generate map of BIFs from a **greyscale** image using `bifs = mtBifs(inputImage, blurWidth, flatnessThreshold)`

Display the map of BIFs using `bifs.show()`

Run tests to verify the output of mtBifs for canonical features for each BIF class using one of:

`mtBifs_test(1);` to print a test report in the Matlab command window (`mtBifs_test(2);` for failing tests only)

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

Gradient, line and saddle BIFs also have an associated orientation, which is also
computed for these features. Note that for line and saddle BIFs, orientations
separated by 180 &deg; are equivalent. However, the library does not yet
canonicalise these to a single orientation.

## References
Crosier, M. & Griffin, L. D. (2010). Using Basic Image Features for Texture Classification. 
International Journal of Computer Vision, 88, 447-460, doi:10.1007/s11263-009-0315-0

[Published paper](http://dx.doi.org/10.1007/s11263-009-0315-0) from journal site | 
[Author version](http://discovery.ucl.ac.uk/74308/) from UCL's institutional repository.

Lillholm, M. & Griffin, L. D. (2008). Novel image feature alphabets for object recognition. 
19th International Conference on Pattern Recognition (ICPR), 1-4, doi:10.1109/ICPR.2008.4761173

[Published paper](http://dx.doi.org/10.1109/ICPR.2008.4761173) from journal site | 
[Author version](http://www.cs.ucl.ac.uk/fileadmin/UCL-CS/images/CGVI/Lewis2.pdf) from UCL's CS department.