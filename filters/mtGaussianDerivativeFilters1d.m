function [s0, s1, s2] = mtGaussianDerivativeFilters1d(sigma)
%mtGaussianDerivativeFilters1d
% Generates discrete zeroth, first and second order 1D Gaussian Derivative 
% filters
% 
% INPUTS:
% sigma: Standard deviation of Gaussian used to generate filters
% 
% OUTPUTS:%
% s0: zeroth order 1D filter
% s1: first-order 1D filter
% s2: second-order 1D filter
%
% USAGE: [s0, s1, s2] = mtGaussianDerivativeFilters1d(sigma)

%% Implementation notes
% Generate filters at higher resolution then downsample filters back down to  
% original resolution by integrating oversampled bins. The goal is to mitigate 
% against rounding issues for small filters and ensure symmetric filters are
% symmetric

% Force numeric parameters to be doubles to avoid errors due to mixing integers 
% and doubles when performing calculations.
sigma = double(sigma);

%% Internal parameters
% scaleFactor: Number of bins in higher resolution filter for each bin in  
%              original resolution filter
% widthMulti: Filters are centered on the middle bin. The extent of the filter 
%             either side of this central pixel is widthMulti standard 
%             deviations
scaleFactor = 10;
widthMulti = 5;
halfWidth = (ceil(sigma)*widthMulti) + 1;

% Set x values for each bin of high resolution filter. Note that the x limits 
% are the same, we just generate more bins between them
xHighRes = -halfWidth:1/scaleFactor:halfWidth;

% Zeroth order filter
s0HighRes = mtGaussianDerivativeFilter1d_s0(xHighRes,sigma);
s0 = mtDownsampleFilter(s0HighRes,scaleFactor);
% First-order filter
if nargout > 1
    s1R = mtGaussianDerivativeFilter1d_s1(xHighRes,sigma);
    s1 = mtDownsampleFilter(s1R,scaleFactor);
end
% Second-order filter
if nargout > 2
    s2R = mtGaussianDerivativeFilter1d_s2(xHighRes,sigma);
    s2 = mtDownsampleFilter(s2R,scaleFactor);
end

