function s1 = mtGaussianDerivativeFilter1d_s1(x, sigma)
% mtGaussianDerivativeFilter1d_s1
% Generate discrete first-order 1D Gaussian Derivative filter
% 
% INPUTS:
% sigma: Standard deviation of Gaussian used to generate filter
% 
% OUTPUTS:
% s1: first order 1D filter
%
% USAGE: s1 = mtGaussianDerivativeFilter1d_s1(sigma)

s0 = mtGaussianDerivativeFilter1d_s0(x,sigma);
s1 = (x/(sigma^2)).* s0;