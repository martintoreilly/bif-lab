function s2 = mtGaussianDerivativeFilter1d_s2(x, sigma)
% mtGaussianDerivativeFilter1d_s2
% Generate discrete second-order 1D Gaussian Derivative filter
% 
% INPUTS:
% sigma: Standard deviation of Gaussian used to generate filter
% 
% OUTPUTS:
% s2: second order 1D filter
%
% USAGE: s2 = mtGaussianDerivativeFilter1d_s2(sigma)

s0 = mtGaussianDerivativeFilter1d_s0(x,sigma);
s2 = ((x.^2-sigma^2)/(sigma^4)) .* s0;