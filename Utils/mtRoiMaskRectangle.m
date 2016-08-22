function [roiMask,X,Y] = mtRoiMaskRectangle(width, height)
%mtRoiMaskRectangle
% Generates a rectangular region of interest (ROI) mask. All pixels wihtin the 
% mask are set to 1 and all pixels outside the mask are set to 0. For a square 
% ROI, set width and height equal.
% 
% INPUTS:
% width: Width of ROI (number of columns)
% height: Height of ROI (number of rows)
%
% OUTPUTS:
% roiMask: Binary (softFlag = FALSE) or weighted (softFlag = TRUE) ROI mask.
% X: x-coordinates of pixels relative to centre of mask.
% Y: y-coordinates of pixels relative to centre of mask.
%
% USAGE: [roiMask,X,Y] = mtRoiMaskRectangle(roiWidth, roiHeight)


halfWidth = (width-1)/2;
halfHeight = (height-1)/2;
x = -halfWidth:halfWidth;
y = -halfHeight:halfHeight;
[X,Y] = meshgrid(x,y);

if(mtRound(width)~=width || mtRound(height)~=height)
    error('mtRoiMaskRectangle:NonIntegerDimensions',...
        'Width and height must be integers');
end

% "Hard" binary mask
roiMask = ones(height,width);

end
