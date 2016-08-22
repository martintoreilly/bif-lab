function [roiMask,X,Y] = mtRoiMaskAnnulus(rInner, rOuter, softFlag, rMax)
%mtRoiMaskAnnulus
% Generates an annular region of interest (ROI) mask. All pixels wihtin the mask
% are set to 1 and all pixels outside the mask are set to 0. If softFlag is set,
% edge pixels are included in proportion to the volume of the pixel in the ROI
% and have fractional values between 0 and 1. For a circular ROI, set rInner 
% to zero.
% 
% INPUTS:
% rInner: Inner radius of annulus. For a circular ROI, set rInner to zero.
% rOuter: Outer radius of annulus
% softFlag: Sets whether to include edge pixels in proportion to the volume of
%           pixel in the ROI (i.e. to fractional values between 0 and 1).
%
% OUTPUTS:
% roiMask: Binary (softFlag = FALSE) or weighted (softFlag = TRUE) ROI mask.
% X: x-coordinates of pixels relative to centre of mask.
% Y: y-coordinates of pixels relative to centre of mask.
%
% USAGE: [roiMask,X,Y] = mtRoiMaskAnnulus(rInner, rOuter, softFlag)

if rInner>=rOuter
    error('rInner must be less than rOuter')
end
s = -ceil(rOuter):ceil(rOuter);
[X,Y] = meshgrid(s,s);
rMask = sqrt(X.^2 + Y.^2);

if(softFlag)
    % "Soft" weighted mask
    % Gives gives a more gradual movement of the ROI edges than a hard binary 
    % mask by including parts of pixels on the ROI border in approximate 
    % proportion to the volume of the pixel within the ROI
    % NOTE: This doesn't take into account the fact that the proportion of the 
    % pixel that lies within the ROI is angle dependent. However, it gives a
    % closer approximation to the analytical roi area given by 
    % pi*(rOuter^2-rInner^2) than the hard binary mask.
    %
    % The rationale is that any pixel with a centre at radius r covers a range
    % [r-0.5..r+0.5]. Therefore max(0,min(1,rOuter-(rMask-0.5))) is the  
    % proportion of the pixel below rOuter and max(0,min(1,(rMask+0.5)-rInner)) 
    % is the proportion of the pixel above rInner. The minimum of these 
    % represents the proportion of the pixel within the ROI.
    roiMask=min(max(0,min(1,rOuter-(rMask-0.5))),max(0,min(1,(rMask+0.5)-rInner)));
else
    % "Hard" binary mask
    roiMask = ones(size(rMask));
    roiMask(rMask<rInner)=0;
    roiMask(rMask>=rOuter)=0;
end
