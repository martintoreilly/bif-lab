classdef mtBifs
% Class for generating Basic Image Features (BIFs) from images 

    %% Properties
    properties (Access = public)
        Class; % Class of maximally responsive BIF at each pixel in image.  1 = flat (pink); 2 = gradient (grey); 3 = dark blob (black); 4 = light blob (white); 5 = dark line (blue); 6 = light line (yellow); 7 = saddle (green)
        Vx; % Unit x-component of BIF orientation
        Vy; % Unit y-component of BIF orientation
    end
    %% Public static methods
    methods (Access = public, Static)
        function colourMap = colourMap()
            % Generates colour map for use when displaying BIFs
            %
            % OUTPUTS:
            % colourMap: Follows the format of built-in Matlab colour maps. Row N+1 defines
            %            the RGB colour to display for matrix elements with value N. Colours
            %            as per the BIF journal papers from Crosier and Griffin with the
            %            addition of mapping for value 0 in row 1. This is not a valid BIF
            %            class but is required for a valid colour map.
            %               0 = invalid (cyan)
            %               1 = falt (pink)
            %               2 = gradient (grey)
            %               3 = dark blob (black)
            %               4 = light blob (white)
            %               5 = dark line (blue)
            %               6 = light line (yellow)
            %               7 = saddle (green)
            % 
            % USAGE: colourMap = mtBifs.colourMap()

            % Set colours used for BIF colour maps
            bifCyan = [0, 0.5, 0.5];
            bifPink = [1, 0.7, 0.7];
            bifGrey = [0.6, 0.6, 0.6];
            bifBlack = [0, 0, 0];
            bifWhite = [1, 1, 1];
            bifBlue = [0.1, 0.1, 1];
            bifYellow = [0.9, 0.9, 0]; 
            bifGreen = [0, 1, 0];

            colourMap = vertcat(bifCyan,bifPink,bifGrey,bifBlack,bifWhite,bifBlue,...
                        bifYellow,bifGreen);
 
        end
    end
    %% Public instance methods
    methods (Access = public)
        function obj = mtBifs(inputImage, blurWidth, flatnessThreshold) 
        % Creates a BIF object from a 2D image.
        %
        % INPUTS:
        % inputImage: 2D image for which to generate BIFs. Image can be greyscale
        %             (colour images are converted to greyscale to generate BIFs).
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
        % bifs = mtBifs(inputImage, blurWidth, flatnessThreshold, type)
       
            % Setup
            % Require inputImage is 2D matrix
            imSize = size(inputImage);
            if(length(imSize)~= 2)
                if(length(imSize)==3 && imSize(3) == 3)
                    % Treat as RGB image
                    inputImage = rgb2gray(inputImage);
                else
                    error('Bifs:InputNot2dMatrix',...
                        'inputImage must be a 2D matrix');
                end
            end
            % Rename input parameters to terms used in BIF papers.
            % Force numeric parameters to be doubles to avoid errors due to 
            % mixing integers and doubles when performing calculations.
            sigma = double(blurWidth);
            gamma = double(flatnessThreshold);

            % Generate filter responses
            [L, Lx, Ly, Lxx, Lyy, Lxy] = mtBifs.dtgFilterResponsesFromImage(...
                inputImage, sigma);

            % Generate and set BIF classes
            obj.Class = mtBifs.bifClassesFromFilterResponses(sigma, gamma, ...
                L, Lx, Ly, Lxx, Lyy, Lxy); 
            
            % Generate and set BIF orientations
            [obj.Vx, obj.Vy] = obj.bifOrientationsFromFilterResponses(...
                L, Lx, Ly, Lxx, Lyy, Lxy); 
        end
        function imHandle = show(obj, showOrientation) 
        % Display BIFs using same colour scheme as BIF journal papers.
        % Elements with invalid BIF classes will be displayed as cyan.
        % Pink: flat (class 1)
        % Grey: gradient (class 2)
        % Black: dark blob (class 3)
        % White: light blob (class 4)
        % Blue: dark line (class 5)
        % Yellow: light line (class 6)
        % Green: saddle (class 7)
        % 
        % INPUTS:
        % bifs: BIF object
        % [showOrientation]: If TRUE, draw BIF orientation marks. Optional
        %                    (default is FALSE).
        %
        % OUTPUTS:
        % imHandle: Handle to the figure in which the BIFs have been displayed
        %
        % USAGE: imHandle = obj.show(showOrientation)

            % Set BIF class colour map
            bifMap = mtBifs.colourMap();

            % Set all elements with invalid BIF classes to 0, as this has a defined clour
            % mapping
            minValidBifClass = 1;
            maxValidBifClass = 7;
            bifClasses = obj.Class;
            bifClasses(bifClasses<minValidBifClass | bifClasses>maxValidBifClass) = 0;

            % Show bif classes with colour map
            bifImage = ind2rgb(uint8(bifClasses), bifMap);
            imHandle = mtImShow(bifImage);
            
            % Add direction marks if requested
            if(nargin < 2)
                showOrientation = false;
            end
            if(showOrientation)
                [numRows, numCols] = size(obj.Class);
                scale = 0.6;
                lineWidth = 2;
                for r = 1:numRows
                    for c = 1:numCols
                            mtBifs.drawBifDir2d(c,r,scale,scale,lineWidth,...
                                obj.Class(r,c),obj.Vx(r,c),obj.Vy(r,c));
                    end
                end 
            end            
        end        
        function bifSnippet = getSnippet(obj, rows, cols)
        % Creates new BIF object with BIF data for specified rows and columns
        % 
        % INPUTS:
        % rows: rows for which to get BIF data
        % cols: columsn for which to get BIF data
        %
        % OUTPUTS:
        % bifSnippet: mtBifs object containing BIF data for specified rows and columns
        %
        % USAGE: bifSnippet = obj.getSnippet(rows, cols): 
            bifSnippet = obj;
            bifSnippet.Class = bifSnippet.Class(rows, cols);
            bifSnippet.Vx = bifSnippet.Vx(rows, cols);
            bifSnippet.Vy = bifSnippet.Vy(rows, cols);
        end
        function bifHistogram = roiHistograms(obj, roiMask, type)
        % Calculates histograms of BIFs within a sliding window region of
        % interest (ROI).
        % 
        % INPUTS:
        % roiMask: A 2D matrix of weights indicating how much each pixel in the
        %          mask should contribute to the histogram (0 = not at all, 1 =
        %          fully). roiMask pixels with weights between 0 and 1 will
        %          partially contribute to the histogram (used to more
        %          accurately represent ROIs where edges don't lie on pixel
        %          boundaries.
        % type: Type of BIF histogram to calculate
        %       1 = BIF classes only. Bin indexes map directly to classes
        %           Bin 1: flat (class 1)
        %           Bin 2: gradient (class 2)
        %           Bin 3: dark blob (class 3)
        %           Bin 4: light blob (class 4)
        %           Bin 5: dark line (class 5)
        %           Bin 6: light line (class 6)
        %           Bin 7: saddle (class 7)
        %
        % USAGE: obj.roiHistograms(roiMask, type)
        
            filterMode = 'padded';
            switch(type)
                case(1)
                    numBins = 7;
                    binBifClasses = 1:7;
                    bifHistogram = zeros([size(obj.Class), numBins]);
                    for(binIdx = 1:numBins)
                        bifClassMask = obj.Class == binBifClasses(binIdx);
                        histogramsForClass = mtFilter2d(...
                            roiMask, bifClassMask, filterMode);
                        bifHistogram(:,:,binIdx) = histogramsForClass;
                    end
                otherwise
                    msgId = 'mtBifs.roiHistograms:InvalidHistogramType';
                    msg = 'type must be 1 (BIF classes only)';
                    error(msgId, msg);
            end
        end
    end
    %% Private static methods
    methods (Static, Access = private)
        function [L, Lx, Ly, Lxx, Lyy, Lxy] = dtgFilterResponsesFromImage(...
            inputImage, sigma)
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
        function bifClasses = bifClassesFromFilterResponses(sigma, gamma, ...
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
        function drawBifDir2d(x, y, xScale, yScale, lineWidth, ...
                bifClass, vx, vy)
        % Draw BIF orientation marks
            switch bifClass
                case {0,1,3,4}
                    % Do nothing. No direction associated with these bif classes
                otherwise
                    X1 = [x-(xScale*0.5)*vx,x+(xScale*0.5)*vx];
                    Y1 = [y-(yScale*0.5)*vy,y+(yScale*0.5)*vy];
                    switch bifClass
                        case 2
                            X1 = [x,x+(xScale*0.5)*vx];
                            Y1 = [y,y+(yScale*0.5)*vy];
                            col1 = 'w';
                            X2 = [x-(xScale*0.5)*vx,x];           
                            Y2 = [y-(yScale*0.5)*vy,y];
                            col2 = 'k';
                            line(X1,Y1,'Color',col1,'LineWidth',lineWidth);
                            line(X2,Y2,'Color',col2,'LineWidth',lineWidth);
                        case 5
                            col1 = 'k';
                            line(X1,Y1,'Color',col1,'LineWidth',lineWidth);
                        case 6
                            col1 = 'w';
                            line(X1,Y1,'Color',col1,'LineWidth',lineWidth);
                        case 7
                            col1 = 'k';
                            X2 = [x-(xScale*0.5)*vy,x+(xScale*0.5)*vy];
                            Y2 = [y+(yScale*0.5)*vx,y-(yScale*0.5)*vx];
                            col2 = 'w';
                            line(X1,Y1,'Color',col1,'LineWidth',lineWidth);
                            line(X2,Y2,'Color',col2,'LineWidth',lineWidth);
                    end
            end
        end
    end
    %% Private instance methods
    methods(Access = private)
        function [vx, vy] = bifOrientationsFromFilterResponses(obj, L, Lx, Ly, ...
                Lxx, Lyy, Lxy)
            % Compute unit vector orientation for first order Bif classes
            vx1 = Lx;
            vy1 = Ly;
            norm1 = sqrt(vx1.^2 + vy1.^2);
            vx1 = vx1./norm1;
            vy1 = vy1./norm1;
            % Compute unit vector orientation for second order Bif classes
            % Direction of second order Bif classes is orientation of second
            % Hessian eigenVector.
            % The formulation below has been chosen to be numerically stable
            % as some issues were encountered due to numerical precision 
            % issues when using some other formulations.
            vx2 = -(-Lxx + Lyy + sqrt((Lxx - Lyy).^2 + 4*Lxy.^2))./(2*Lxy);
            vy2 = ones(size(vx2));
            norm2 = sqrt(vx2.^2 + vy2.^2);
            vx2 = vx2./norm2;
            vy2 = vy2./norm2;

            % Fudge for when Lxy = 0 (vx2 formula -> NaN)
            % When Lxy = 0, change is either all in x dir or all in y dir
            fudgeMask = (Lxy==0);
            vertMask = (Lxx > Lyy); % Change all in x dir (vertical ridge)
            horzMask = (Lyy > Lxx); % change all in y dir (horizontal ridge)
            vx2(fudgeMask & vertMask) = 0;
            vy2(fudgeMask & vertMask) = 1;
            vx2(fudgeMask & horzMask) = 1;
            vy2(fudgeMask & horzMask) = 0;
            
            % vx and vy defined to lie along the ridge for for dark ridges. 
            % For light ridges, the sign of the eigenvectors are opposite so 
            % vx and vy actually lie perpendicular to the ridge. Rotate by 90 
            % degrees to make them lie along the ridge (vx, vy) -> (vy, -vx)
            lightMask2 = (obj.Class==6);
            vxOld = vx2;
            vy2Old = vy2;
            vx2(lightMask2) = vy2Old(lightMask2);
            vy2(lightMask2) = -vxOld(lightMask2);            
            
            % Copy appropriate order orientations into output variables
            vx = zeros(size(obj.Class));
            vy = zeros(size(vx));
            % Set first order BIF orientations from vx1 and vy1
            mask1 = (obj.Class==2);
            vx(mask1) = vx1(mask1);
            vy(mask1) = vy1(mask1);
            % Set seconf-order BIF orientations from vx2 and vy2
            mask2 = (obj.Class>=5 & obj.Class <=7);
            vx(mask2) = vx2(mask2);
            vy(mask2) = vy2(mask2);
        end
    end
end