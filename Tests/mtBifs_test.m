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
% OUTPUTS:
% --------
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
    recordFormat = '%s %f %f %d';
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
                expectedBifClass] = extractTestParameters(fields, testFileDir);
            % Run test case
            [currentTestOutcome, currentTestOutcomeDetail] = runTest(...
                testImageFilename, testFileDir, blurWidth,...
                flatnessThreshold, expectedBifClass);
            numTestCases = numTestCases + 1;
            % Log test case outcome
            testOutcomes = [testOutcomes, currentTestOutcome];
            testOutcomeDetails{numTestCases} = currentTestOutcomeDetail;
            if(showTestOutcomes)
                disp(currentTestOutcomeDetail);
            end
        end
        fileLine = fgetl(fileId);
    end
    fclose(fileId);
end % main function

function [testImageFilename, blurWidth, flatnessThreshold, ...
    expectedBifClass] = extractTestParameters(fields, rootDir)
    
    numFields = size(fields,2);
    expectedNumFields = 4;    
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
    
    % Validate fields are of correct type
    mtValidateFilePathParameter(testImageFilename, rootDir);
    mtValidateNumericParameter(blurWidth);
    mtValidateNumericParameter(flatnessThreshold);
    mtValidateNumericParameter(expectedBifClass);
end

function [testOutcome, testOutcomeDetail] = runTest(testImageFilename, ...
    testImDir, blurWidth, flatnessThreshold, expectedBifClass)
    
    testCaseId = ['mtBifs_test:',testImageFilename];
    testImageFilePath = fullfile(testImDir, testImageFilename);
    
    % Load image and compute BIFs
    testImage = imread(testImageFilePath);
    bifs = mtBifs(testImage, blurWidth, flatnessThreshold,1);
    
    % Check central BIFs match expected class
    [bifsMatch, centralPixelBifs] = checkCentralBifsAreExpectedBifClass(...
        bifs.Class, expectedBifClass);
    % Check BIF type is as expected
    expectedBifType = 1;
    bifTypeMatch = (bifs.Type == expectedBifType);
    
    % Record test outcome
    if(bifsMatch && bifTypeMatch)
        testOutcome = true;
        testOutcomeDetail = ['PASS:',testCaseId];
    else   
        testOutcome = false;
        testOutcomeDetail = ['FAIL:',testCaseId];
    end
    testOutcomeDetail = [testOutcomeDetail,...
        '; Expected central BIF class: ', int2str(expectedBifClass),...
        '; Actual central BIF class(es): ', mat2str(centralPixelBifs(:)'),...
        '; Expected BIF type: ', int2str(expectedBifType),...
        '; Actual BIF type: ', int2str(bifs.Type)];
end % runTest

function [bifsMatch, centralPixelBifs] = checkCentralBifsAreExpectedBifClass(...
    bifImage, expectedBifClass)

    [numRows, numCols] = size(bifImage);
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
    centralPixelBifs = bifImage(ctrRows,ctrCols);
    % Check all central pixel(s) match expected BIF class
    numCentralPixels = numel(centralPixelBifs);
    numMatchingCentralPixels = sum(centralPixelBifs(:) == expectedBifClass);
    bifsMatch = (numMatchingCentralPixels == numCentralPixels);
end
