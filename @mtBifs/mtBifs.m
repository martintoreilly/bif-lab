classdef mtBifs
%mtBifs
    properties (Access = public)
        Class; % Class of maximally responsive BIF at each pixel in inputImage. 1 = flat (pink); 2 = gradient (grey); 3 = dark blob (black); 4 = light blob (white); 5 = dark line (blue); 6 = light line (yellow); 7 = saddle (green)
        Type; % BIF type: 1 = BIFs (class only)
    end
    methods (Access = public)
        function obj = mtBifs(inputImage, blurWidth, flatnessThreshold, type)
        %mtBifs(inputImage, blurWidth, flatnessThreshold, type)
        % Generates a BIFs object showing the maxmally responding BIF class at 
        % each pixel of the input image
        %
        % INPUTS:
        % inputImage: 2D greyscale image for which to generate BIFs. Values can
        %             be in any range, but input must be 2D image.
        % blurWidth: Standard deviation of Gaussian used to generate BIF filters.
        % flatnessThreshold: Threshold for 'flat' bif class. Zeroth order BIF response
        %     is multiplied by this threshold factor. The higher the flatness threshold
        %     factor, the more likely a pixel is to be considered flat. A value of 
        %     0.1-0.2 is a reasonable starting point, but the best value will depend 
        %     on the nature of the images used in each application.
        % type: BIF type.
        %       1 = BIFS (class only)
        %
        % OUTPUTS:
        % bifImage: A 2D matrix the same size as the input image. Elements are in the
        %     range 1..7 inclusive, with integers mapping to BIF classes as follows:
        %     1 = flat (pink); 2 = gradient (grey); 3 = dark blob (black); 
        %     4 = light blob (white); 5 = dark line (blue); 6 = light line (yellow); 
        %     7 = saddle (green)
        %
        % USAGE:
        % bifs = mtBifs(inputImage, blurWidth, flatnessThreshold, type)
       
            %% Setup
            % Require inputImage is 2D matrix
            imSize = size(inputImage);
            if(length(imSize)~= 2)
                error('Bifs:InputNot2dMatrix','inputImage must be a 2D matrix');
            end
            % Require valid BIF type
            validTypes = [1];
            if(~any(validTypes == type))
                error('Bifs:InvalidBifType',['type must be valid BIF type ', ...
                    '(',mat2str(validTypes), '). See help for more information.']);
            end
            % Rename input parameters to terms used in BIF papers.
            % Force numeric parameters to be doubles to avoid errors due to 
            % mixing integers and doubles when performing calculations.
            sigma = double(blurWidth);
            gamma = double(flatnessThreshold);
            % Set BIF type
            obj.Type = type;

            %% Generate filter responses
            [L, Lx, Ly, Lxx, Lyy, Lxy] = obj.dtgFilterResponsesFromImage(...
                inputImage, sigma);

            %% Generate BIF classes
            obj.Class = obj.bifClassesFromFilterResponses(sigma, gamma, ...
                L, Lx, Ly, Lxx, Lyy, Lxy);           
        end
    end
    methods (Access = private)
        function [L, Lx, Ly, Lxx, Lyy, Lxy] = dtgFilterResponsesFromImage(...
                ~, inputImage, sigma)
            % Generate the 1D Gaussian Derivative filters used to calculate BIFs
            % s0 = zeroth order 1D filter
            % s1 = first-order 1D filter
            % s2 = second-order 1D filter
            [s0, s1, s2] = mtGaussianDerivativeFilters1d(sigma);
            % Calculate 2D filter responses over the image using the 1D filters
            % Pad extended boundary so filter response is same size as input 
            % image and pad boundary with reflected edge pixels
            filterMode = 'mirror'; 
            % zeroth order filter
            L = mtSeparableFilter2(s0,s0,inputImage,filterMode); 
            % first-order in x, zeroth in y
            Lx = mtSeparableFilter2(s1,s0,inputImage,filterMode); 
            % first-order in y, zeroth in x
            Ly = mtSeparableFilter2(s0,s1,inputImage,filterMode); 
            % second-order in x, zeroth in y
            Lxx = mtSeparableFilter2(s2,s0,inputImage,filterMode); 
            % second-order in y, zeroth in x
            Lyy = mtSeparableFilter2(s0,s2,inputImage,filterMode); 
            % first-order in x and y
            Lxy = mtSeparableFilter2(s1,s1,inputImage,filterMode); 
        end
        function bifClasses = bifClassesFromFilterResponses(~, sigma, gamma, ...
                L, Lx, Ly, Lxx, Lyy, Lxy)
            numBifClasses = 7;
            [numYs,numXs] = size(L);
            jetScore = zeros([numYs,numXs,numBifClasses]);
            % 1: flat (pink)
            jetScore(:,:,1) = gamma*L; 
            % 2: gradient (grey)
            jetScore(:,:,2) = sigma*sqrt(Lx.^2 + Ly.^2); 
            % Second order BIFs are calculated from Hessian eigenvalues. 
            % The formulation below has been chosen to be numerically stable
            % as some issues were encountered due to numerical precision 
            % issues when using some other formulations.
            eigVal1 = (Lxx + Lyy + sqrt((Lxx - Lyy).^2 + 4*Lxy.^2))/2; 
            eigVal2 = (Lxx + Lyy - sqrt((Lxx - Lyy).^2 + 4*Lxy.^2))/2;
            % 3: dark blob (black)
            jetScore(:,:,3) = sigma^2*(eigVal1 + eigVal2)/2; 
            % 4: light blob (white)
            jetScore(:,:,4) = -sigma^2*(eigVal1 + eigVal2)/2;
            % 5: dark ridge (blue)
            jetScore(:,:,5) = sigma^2*eigVal1/sqrt(2); 
            % 6: light ridge (yellow)
            jetScore(:,:,6) = -sigma^2*eigVal2/sqrt(2); 
            % 7: saddle (green)
            jetScore(:,:,7) = sigma^2*(eigVal1 - eigVal2)/2; 
            % Get maximum BIF score at each pixel (index in third dimension 
            % corresponds to integer code for BIF class)
            [~, bifClasses] = max(jetScore,[],3);
        end
    end
end