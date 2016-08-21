function mtBifs_test_show(titleText, testImage, bifs, centreRows, centreCols)
%mtBifs_test_show
% Displays testImage and BIFs for visual inspection

%% Open figure
figure('name',titleText);

%% Show test image
subplot(1,3,1);
numDims = length(size(testImage));
if(numDims == 2)
    % Convert greyscale image to RGB image
    testImage = ind2rgb(testImage, gray(256));
end
mtImShow(testImage);
xlabel('Test image');

%% Show BIF classes for whole image
subplot(1,3,2);
bifs.show(0);
xlabel('BIF class for all pixels');

%% Show BIF classes and orientation for central pixel(s)
subplot(1,3,3);
bifs.getSnippet(centreRows, centreCols).show(1);
xlabel(['BIF class and orientation',char(10),'for central pixel(s)']);