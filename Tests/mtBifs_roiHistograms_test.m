function [testOutcomes, testOutcomeDetails] = ...
    mtBifs_roiHistograms_test(showTestOutcomes)
%mtBifs_roiHistograms_test
% Tests that rolling window BIF histograms are correctly calculated.
%
% INPUTS:
% showTestOutcomes: 0 = don't show test outcome; 1 = print test outcome during
%                   test; 2 = print test outcome and show BIFs and test images
%                   for manual verification.
%
% OUTPUTS:
% testOutcomes: Vector giving pass / fail outcome of each test (TRUE = pass).
% testOutcomeDetails: Cell array with text giving more detail of outcome of 
%                     each test.
%
% USAGE: [testOutcomes, testOutcomeDetails] = mtBifs_roiHistograms_test(showOutcomes)

    if(nargin == 0)
        showTestOutcomes = 0;
    end    
    testOutcomes = [];
    numTestCases = 0;
    %% Car
    numTestCases = numTestCases + 1;
    % Set run-specifc paramters
    filename = 'all_features_sigma=5.png';
    zoomCtrRow = 41; zoomCtrCol = 64; sigma = 5; gamma = 0.05
    [currentTestOutcome, currentTestOutcomeDetail] = runTest(filename, ...
        sigma, gamma, zoomCtrRow, zoomCtrCol, showTestOutcomes);
    % Log test case outcome
    testOutcomes = [testOutcomes, currentTestOutcome];
    testOutcomeDetails{numTestCases} = currentTestOutcomeDetail;
end

function [testOutcome, testOutcomeDetail] = runTest(filename, sigma, gamma, ...
    zoomCtrRow, zoomCtrCol, showTestOutcomes)
    
    % Set common parameters    
    imDir = fullfile('.','mtBifs_roiHistograms_test_files');
    roiHalfWidth = 15;
    roiHalfHeight = 12;
    % Set run specific parameters
    testCaseId = filename;
    roiRows = zoomCtrRow+[-roiHalfHeight:roiHalfHeight];
    roiCols = zoomCtrCol+[-roiHalfWidth:roiHalfWidth];
    % Gerate ROI mask
    roiWidth = (roiHalfWidth*2) + 1;
    roiHeight = (roiHalfHeight*2) + 1;
    roiMask = mtRoiMaskRectangle(roiWidth,roiHeight);
    % Generate BIFs
    im = imread(fullfile(imDir,filename));
    bifs = mtBifs(im, sigma, gamma);
    % Calculate BIF class-only histograms (type 1) using code under tests
    bifHistsActual = bifs.roiHistograms(roiMask, 1);
    % Calculate BIF class-only histograms the slow, reliable way
    disp(['Starting reliable BIF calcualtion for ',testCaseId,' (slow)']);
    bifHistsExpected = reliableBifHistograms(bifs, roiMask, 1);
    % Compare actual and expected valid historgams
    nanReplacement = -1;
    bifHistsActual(isnan(bifHistsActual)) = nanReplacement;
    bifHistsExpected(isnan(bifHistsExpected)) = nanReplacement;
    matchCount = sum(bifHistsActual(:) == bifHistsExpected(:));
    totalHistBins = length(bifHistsExpected(:));
    % Set test outcome and message
    if(matchCount < totalHistBins)
        testOutcome = false;
        testOutcomeDetail = ['FAIL:',testCaseId];
    else
        testOutcome = true;
        testOutcomeDetail = ['PASS:',testCaseId];
    end
    testOutcomeDetail = [testOutcomeDetail,'; ', num2str(matchCount)...
        ' of ',num2str(totalHistBins),' histogram bins match.'];
    % Display outcoem if requested
    if(showTestOutcomes>0)
        disp(testOutcomeDetail);
        if(showTestOutcomes>1)
            mtShowCaseBifs(testCaseId, im, bifs, roiRows, roiCols);
        end
    end
    
    % %% Tunnel
    % filename = 'tunnel.jpg';
    % im = imread(fullfile(imDir,filename));
    % bifs = mtBifs(im, 3.5, 0.015);
    % mtShowCaseBifs(filename,im,bifs,40:75,40:75);
end % main function

function bifHistograms = reliableBifHistograms(bifs, roiMask, type)

    [roiRows,roiCols]=size(roiMask);
    % check roiMask is odd in both dimensions (therefore has a centre pixel)
    if ~isequal(mod([roiRows,roiCols],2),[1 1])
        error('roiMask must have dimensions of odd length');
    end
    roiHalfWidth = (roiCols-1)/2;
    roiHalfHeight = (roiRows-1)/2;

    [bifRows,bifCols] = size(bifs.Class);
    switch(type)
        case(1)
            numBins = 7;
            bifHistograms = NaN([bifRows,bifCols,numBins]);
            binBifClasses = 1:7;
            for binIdx = 1:numBins
                disp(['Calculating bin ',num2str(binIdx),' of ',...
                    num2str(numBins)]);
                for rowIdx = roiHalfHeight+1:bifRows-roiHalfHeight
                    for colIdx = roiHalfWidth+1:bifCols-roiHalfWidth
                        snippetRows = rowIdx-roiHalfHeight:rowIdx+roiHalfHeight;
                        snippetCols = colIdx-roiHalfWidth:colIdx+roiHalfWidth;
                        bifMatchPxs = (bifs.Class(snippetRows,snippetCols) == ...
                            binBifClasses(binIdx));
                        bifHistograms(rowIdx, colIdx ,binIdx) = ...
                            sum(bifMatchPxs(:) & roiMask(:));                      
                    end
                end
            end
        otherwise
            msgId = 'reliableBifHistograms:InvalidHistogramType';
            msg = 'type must be 1 (BIF classes only)';
            error(msgId, msg);
    end
end