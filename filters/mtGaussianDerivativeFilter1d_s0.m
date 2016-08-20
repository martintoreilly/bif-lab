function s0 = mtGaussianDerivativeFilter1d_s0(x, sigma)
% mtGaussianDerivativeFilter1d_s0
% Generate discrete zeroth-order 1D Gaussian Derivative filter
% 
% INPUTS:
% sigma: Standard deviation of Gaussian used to generate filter
% 
% OUTPUTS:
% s0: zeroth order 1D filter
%
% USAGE: s0 = mtGaussianDerivativeFilter1d_s0(sigma)

Cs = 1/(sqrt(2*pi)*sigma);
s0 = Cs*exp(-x.^2/(2*sigma^2));
