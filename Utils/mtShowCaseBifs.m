function mtShowCaseBifs(titleText, image, bifs, zoomRows, zoomCols)
%mtShowCaseBifs
% Displays image and BIFs for visual inspection. Three panels are shown as
% follows:
% - Left: entire input
% - Middle: BIF classes for entire image
% - Right: BIF classes and orientations for the specified rows and columns
%
%
% INPUTS:
% titleText: Text to dislay in figure window
% image: input image for which BIFs have been calculated
% bifs: mtBifs object with BIF classes and orientations for entire image
% zoomRows: Rows to zoom in and show BIF orientations for
% zoomCols: Columns to zoom in and show BIF orientations for
%
% NOTE: It is recommended to show orientations only for small image areas 
% (say up to about 50x50 pixels). For larger areas, it can be hard to 
% distinguish the orientations and Matlab's image display features tend to 
% get a bit slow.
%
% USAGE: mtShowCaseBifs(titleText, image, bifs, zoomRows, zoomColumns)

% Open figure
figure('name',titleText);

% Set bounding box for zoomed area
xMin = min(zoomCols);
xMax = max(zoomCols);
yMin = min(zoomRows);
yMax = max(zoomRows);
X = [xMin,xMin,xMax,xMax,xMin];
Y = [yMin,yMax,yMax,yMin,yMin];

% Show test image
subplot(2,2,1);
numDims = length(size(image));
if(numDims == 2)
    % Convert greyscale image to RGB image
    image = ind2rgb(image, gray(256));
end
mtImShow(image);
line(X,Y,'color',[0,1,1]);
xlabel('Test image');

% Show BIF classes for whole image
subplot(2,2,2);
bifs.show(0);
line(X,Y,'color',[0,1,1]);
xlabel('BIF class for all pixels');

% Show image for zoomed pixel(s)
subplot(2,2,3);
mtImShow(image(zoomRows, zoomCols, :));
xlabel(['Image for zoomed area']);

% Show BIF classes and orientation for zoomed pixel(s)
subplot(2,2,4);
bifs.getSnippet(zoomRows, zoomCols).show(1);
xlabel(['BIF class and orientation',char(10),'for zoomed area']);