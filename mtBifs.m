function bifImage = mtBifs(inputImage, blurWidth, flatnessThreshold)
%mtBifs
% Generates a BIF image showing the maxmally responding BIF class at each pixel
% of the input image
%
% INPUTS:
% inputImage: Greyscale image for which to generate BIFs.
% blurWidth: Standard deviation of Gaussian used to generate BIF filters.
% flatnessThreshold: Threshold for 'flat' bif class. Zeroth order BIF response
%     is multiplied by this threshold factor. The higher the flatness threshold
%     factor, the more likely a pixel is to be considered flat. A value of 
%     0.1-0.2 is a reasonable starting point, but the best value will depend 
%     on the nature of the images used in each application.
%
% OUTPUTS:
% bifImage: A 2D matrix the same size as the input image. Elements are in the
%     range 1..7 inclusive, with integers mapping to BIF classes as follows:
%     1 = flat (pink); 2 = gradient (grey); 3 = dark blob (black); 
%     4 = light blob (white); 5 = dark line (blue); 6 = light line (yellow); 
%     7 = saddle (green)
%
% USAGE:
% bifImage = mtBifs(inputImage, blurWidth, flatnessThreshold)

%% Setup
% Rename input parameters to terms used in BIF papers.
% Force numeric parameters to be doubles to avoid errors due to mixing integers 
% and doubles when performing calculations.
sigma = double(blurWidth);
gamma = double(flatnessThreshold);

%% Generate filter responses
% Generate the 1D Gaussian Derivative filters used to calculate the BIFs
% s0 = zeroth order 1D filter
% s1 = first-order 1D filter
% s2 = second-order 1D filter
[s0, s1, s2] = mtGaussianDerivativeFilters1d(sigma);
% Calculate 2D filter responses over the image using the 1D filters
filterMode = 'mirror';
L = mtSeparableFilter2(s0,s0,inputImage,filterMode); % zeroth order filter
Lx = mtSeparableFilter2(s1,s0,inputImage,filterMode); % first-order in x, zeroth in y
Ly = mtSeparableFilter2(s0,s1,inputImage,filterMode); % first-order in y, zeroth in x
Lxx = mtSeparableFilter2(s2,s0,inputImage,filterMode); % second-order in x, zeroth in y
Lyy = mtSeparableFilter2(s0,s2,inputImage,filterMode); % second-order in y, zeroth in x
Lxy = mtSeparableFilter2(s1,s1,inputImage,filterMode); % first-order in x and y

%% Generate scores for each BIF
numBifClasses = 7;
[numYs,numXs] = size(L);
jetScore = zeros([numYs,numXs,numBifClasses]);
jetScore(:,:,1) = gamma*L; % 1: flat (pink)
jetScore(:,:,2) = sigma*sqrt(Lx.^2 + Ly.^2); % 2: gradient (grey)
% Second order BIFs are calculated from Hessian eigenvalues. The formulation
% below has been chosen to be numerically stable as some issues were encountered
% due to numerical precision issues when using some other formulations.
eigVal1 = (Lxx + Lyy + sqrt((Lxx - Lyy).^2 + 4*Lxy.^2))/2; 
eigVal2 = (Lxx + Lyy - sqrt((Lxx - Lyy).^2 + 4*Lxy.^2))/2;
jetScore(:,:,3) = sigma^2*(eigVal1 + eigVal2)/2; % 3: dark blob (black)
jetScore(:,:,4) = -sigma^2*(eigVal1 + eigVal2)/2; % 4: light blob (white)
jetScore(:,:,5) = sigma^2*eigVal1/sqrt(2); % 5: dark ridge (blue)
jetScore(:,:,6) = -sigma^2*eigVal2/sqrt(2); % 6: light ridge (yellow)
jetScore(:,:,7) = sigma^2*(eigVal1 - eigVal2)/2; % 7: saddle (green)
% Get maximum BIF score at each pixel (index in third dimension corresponds to
% integer code for BIF class)
[~, bifImage] = max(jetScore,[],3);
