# BifLib
A MATLAB library for efficiently generating Basic Image Features (BIFs) from images.

## Quick start
### Install
Type `mtInstallBifLab` at the Matlab command line to add BifLab folders to 
Matlab path

### Demo
Type `mtDemoBifLab` at the Matlab command line to display demonstration images 
and their associated BIFs

### Generate BIFs
Generate BIFs from an image using `bifs = mtBifs(inputImage, blurWidth, flatnessThreshold)`

`blurWidth` (&sigma; in the reference papers) sets the scale of the features that the BIFs detect. It is the 
standard deviation of the gaussian derivative filters used to 
calculate the BIF responses .

`flatnessThreshold` (&gamma; in the reference papers) is a threshold factor used to control the minimal response
required for a non-flat BIF to be returned. This ensures that the flat BIF is 
selected where there is no strong response from any other BIF. The higher the 
flatness threshold factor, the more likely a pixel is to be considered flat. 
A value of 0.1-0.2 is a reasonable starting point. However, the best value will 
depend on the nature of the images used in each application so some experimentation
is recommended.

### Display BIFs
Display BIFs using `bifs.show(0)` (BIF classes only) or `bifs.show(1)` (BIF classes and orientations). 
If no parameter is provided, the default is to show classes only.

It is recommended to show 
orientations only for small image areas (say up to about 50x50 pixels). For larger
areas, it can be hard to distinguish the orientations and Matlab's image display 
features tend to get a bit slow.

`bifs.getSnippet(rows, columns)` can be used to easily get a snippet of a larger 
set of BIFs for display or further processing.

### Further documentation
For further documentation of the BIF class, including its properties and methods, 
type `doc mtBifs` at the Matlab command line.

## Introduction to BIFs
BIFs are a classification of local image structure into seven different classes on the basis of approximate local symmetry. 
The seven classes are:

1 = _flat_ (pink). No orientation.

2 = _gradient_ (grey). Orientation is "up" luminance gradient from dark to light.

3 = _dark blob_ (black). No orientation.

4 = _light blob_ (white). No orientation.

5 = _dark line_ (blue). Orientation is along dark ridge.

6 = _light line_ (yellow). Orientation is along light ridge.

7 = _saddle_ (green). Orientation is along dark ridge.

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

## Tests
### BIF classes and orientations
Run tests to verify the output of the library for canonical features for each BIF class using one of:

`mtBifs_test(1);` to print a test report in the Matlab command window.

`mtBifs_test(2);` to print test report and also show test images and BIFs for manual verification.

`[testOutcomes, testOutcomeDetails] = mtBifs_test(0);` to save the test outcomes 
and outcome messages for further processing with no printed output.

For more information on running the provided tests and defining additional test 
cases of your own, type `doc mtBifs_test` at the Matlab command line.

### BIF histograms
Run a test to verify the fast BIF histogram generation code produces the same
BIF histograms as an idiot-proof pixel-by-pixel calculation using one of:

`mtBifs_roiHistograms_test(1);` to print a test report in the Matlab command window.

`mtBifs_roiHistograms_test(2);` to print test report and also show test image, 
BIFs and sample histogram for manual verification.

`[testOutcomes, testOutcomeDetails] = mtBifs_roiHistograms_test(0);` to save the test outcomes 
and outcome messages for further processing with no printed output.

## Citation
O'Reilly, Martin (2016): BifLib Matlab BIF library. figshare.
[doi:10.6084/m9.figshare.3749217](https://dx.doi.org/10.6084/m9.figshare.3749217)