function [testOutcomes, testOutcomeDetails] = mtBifs_test(showTestOutcomes)
%mtBifs_test
% Tests that the canonical features detected by each BIF are classified 
% correctly. Gets input from a test definitions file and associated
% test images.
%
% TEST DEFINITIONS:
% -----------------
% Test definitions are set in ./mtBifs_test_files/test_definitions.txt
%
% Blank lines and comment lines are ignored.
% Comment lines begin with %
%
% Each test definition line should be 4 comma-separated values as follows. Any 
% additional fields will be silently ignored. Too few fields will cause the test
% to fail with an error.
% 1. Test image filename. Images should be 100x100 pixels. Each feature should 
%    contain a single centralised test feature. Image filenames should not 
%    contain spaces. Images should be stored in the same folder as this file.
% 2. BIF blurWidth parameter (sigma)
% 3. BIF flatnessThreshold parameter (gamma)
% 4. Expected BIF class for central pixel(s) of image.
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
% USAGE: [testOutcomes, testOutcomeDetails] = mtBifs_test(showOutcomes)

    % Define folder containing test images and test definitions file, along with
    % path to test definitions file, test definition format, comment and 
    % delimiter characters
    [rootDir, ~, ~] = fileparts(mfilename('fullpath'));
    testFileDir = fullfile(rootDir,'mtBifs_test_files');
    testDefinitionsFilename = 'test_definitions.txt';
    testDefinitionsFilePath = fullfile(testFileDir,testDefinitionsFilename);
    recordFormat = '%s %f %f %d %f %f';
    commentChar = '%';
    fieldDelimiter = ',';
    
    if(nargin == 0)
        showTestOutcomes = false;
    end
    testOutcomes = [];

    % Read in test definitions from test definition file and run tests.
    % See function help comment for test definition format notes.
    mtValidateFilePathParameter(testDefinitionsFilePath);
    fileId = fopen(testDefinitionsFilePath);
    fileLine = fgetl(fileId);
    lineNum = 0;
    numTestCases = 0;
    while ischar(fileLine)
        lineNum = lineNum + 1;
        isEmptyLine = isempty(fileLine);
        if(~isEmptyLine)
            isCommentLine = (fileLine(1) == commentChar);
        end
        if(~isEmptyLine && ~isCommentLine)
            % Read and validate test definition
            fields = textscan(fileLine, recordFormat, 'delimiter', ...
                fieldDelimiter);
            [testImageFilename, blurWidth, flatnessThreshold, ...
                expectedBifClass,expectedBifVx, expectedBifVy] ...
                = extractTestParameters(fields, testFileDir);
            % Run test case
            [currentTestOutcome, currentTestOutcomeDetail] = runTest(...
                testImageFilename, testFileDir, blurWidth,...
                flatnessThreshold, expectedBifClass, expectedBifVx, ...
                expectedBifVy, showTestOutcomes);
            numTestCases = numTestCases + 1;
            % Log test case outcome
            testOutcomes = [testOutcomes, currentTestOutcome];
            testOutcomeDetails{numTestCases} = currentTestOutcomeDetail;
        end
        fileLine = fgetl(fileId);
    end
    fclose(fileId);
end % main function

function [testImageFilename, blurWidth, flatnessThreshold, ...
    expectedBifClass, expectedBifVx, expectedBifVy] ...
    = extractTestParameters(fields, rootDir)
    
    numFields = size(fields,2);
    expectedNumFields = 6;    
    if(numFields ~= expectedNumFields)
        msgId = [mfilename,':InvalidTestDefinition'];
        msg = ['Line ',lineNum,' does not contain a valid test ',...
            'definition or comment'];
        error(msgId, msg);
    end
    
    % Extract fields
    testImageFilename = fields{1}{1};
    blurWidth = fields{2};
    flatnessThreshold = fields{3};
    expectedBifClass = fields{4};
    expectedBifVx = fields{5};
    expectedBifVy = fields{6};
    
    % Validate fields are of correct type
    mtValidateFilePathParameter(testImageFilename, rootDir);
    mtValidateNumericParameter(blurWidth);
    mtValidateNumericParameter(flatnessThreshold);
    mtValidateNumericParameter(expectedBifClass);
    mtValidateNumericParameter(expectedBifVx);
    mtValidateNumericParameter(expectedBifVy);
end

function [testOutcome, testOutcomeDetail] = runTest(testImageFilename, ...
    testImDir, blurWidth, flatnessThreshold, expectedBifClass, ...
    expectedBifVx, expectedBifVy, showTestOutcomes)
    
    testCaseId = ['mtBifs_test:',testImageFilename];
    testImageFilePath = fullfile(testImDir, testImageFilename);
    
    % Load image and compute BIFs
    testImage = imread(testImageFilePath);
    bifs = mtBifs(testImage, blurWidth, flatnessThreshold);
    
    % Get central BIFs
    [centralBifs, ctrRows, ctrCols] = getCentralBifs(bifs);
    
    % Check central BIFs match expected class
    bifClassesMatch = checkAllBifsAreExpectedClass(...
        centralBifs, expectedBifClass);
    % Check central BIFs have expected orientation
    maxDiff = 0.005;
    bifOrientationsMatch = checkAllBifsAreExpectedOrientation(...
        centralBifs, expectedBifVx, expectedBifVy, maxDiff);
    
    % Record test outcome
    if(bifClassesMatch && bifOrientationsMatch)
        testOutcome = true;
        testOutcomeDetail = ['PASS:',testCaseId];
    else   
        testOutcome = false;
        testOutcomeDetail = ['FAIL:',testCaseId];
    end
    testOutcomeDetail = [testOutcomeDetail,...
        '; Expected: c=', num2str(expectedBifClass),...
        '; vx=', num2str(mtRound(expectedBifVx,maxDiff)),...
        '; vy=', num2str(mtRound(expectedBifVy,maxDiff)),...
        '; Actual: c=', mat2str(centralBifs.Class(:)'),...
        '; vx=', mat2str(mtRound(centralBifs.Vx(:)',maxDiff))...
        '; vy=', mat2str(mtRound(centralBifs.Vy(:)',maxDiff))];
    
    if(showTestOutcomes>0)
        disp(testOutcomeDetail);
        if(showTestOutcomes>1)
            mtBifs_test_show(testImageFilename, testImage, bifs, ...
                ctrRows, ctrCols);
        end
    end            
end % runTest

function [centralBifs, ctrRows, ctrCols] = getCentralBifs(bifs)
    [numRows, numCols] = size(bifs.Class);
    % Get central row(s)
    if(mtIsOdd(numRows))
        ctrRows = ceil(numRows/2);
    else
        ctrRows = [(numRows/2),(numRows/2)+1];
    end
    % Get central column(s)
    if(mtIsOdd(numCols))
        ctrCols = ceil(numCols/2);
    else
        ctrCols = [(numCols/2),(numCols/2)+1];
    end
    centralBifs = bifs.getSnippet(ctrRows, ctrCols);
end

function allBifClassesMatch = checkAllBifsAreExpectedClass(bifs, expectedClass)

    % Check all BIF classes match expected class
    if(any(bifs.Class(:)~=expectedClass))
        allBifClassesMatch = false;
    else
        allBifClassesMatch = true;
    end
end

function allBifOrientationsMatch = checkAllBifsAreExpectedOrientation(...
    bifs, expectedVx, expectedVy, maxDiff)

    % Check all BIF classes match expected orientation
    vxDiff = abs(bifs.Vx(:) - expectedVx);
    vyDiff = abs(bifs.Vy(:) - expectedVy);
    if(any(vxDiff>maxDiff) || any(vyDiff>maxDiff))
        allBifOrientationsMatch = false;
    else
        allBifOrientationsMatch = true;
    end
end
