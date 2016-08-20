function outFilter = mtDownsampleFilter(inFilter, scaleFactor)
%mtDownsampleFilter
% Downsamples 1D or 2D filters by averaging across scaleFactor bins. Generating 
% a discrete filter at a higher resolution than required and then downsampling 
% to the required resolution can often help produce a more accurate filter 
% representation. This is especially true where filters will have a low
% resolution and it is important to preserve symmetry.
%
% INPUTS:
% scaleFactor: Factor by which to downsample the input filter. Defines the
%              number of bins in each dimension to average over and collapse 
%              into a single bin in the output filter
%
% OUTPUTS:
% outFilter: Downsampled filter
%
% USAGE: outFilter = mtDownsampleFilter(inFilter, scaleFactor, ctrPx)

%% Generate averaging filter
% Determine if inpout filter is 1D or 2D
if size(inFilter,1) == 1 || size(inFilter,2) == 1
    numDims = 1;
else
    numDims = 2;
end
% Generate 1D or 2D square rolling window averaging filter
numPixelsInBin = scaleFactor^numDims;
if numDims == 1;
    sampleFilter = ones(1,scaleFactor)/numPixelsInBin;
else
    sampleFilter = ones(scaleFactor,scaleFactor)/numPixelsInBin;
end

%% Calculate rolling window average for each bin in input filter
% We take forward and reverse averages to average out single pixel jitter in
% small even filters (where there is no centre pixel). This ensures symmetrical
% filters remain symmetrical after downsampling.
rollingAverage = filter2(sampleFilter, inFilter, 'valid');
[numRows, numCols] = size(rollingAverage);

%% Determine central bin at which to start subsampling rolling average
% Currently subsampling always starts from the centre of the physical filter. 
% This is appropriate for the symmetric filters used in the calculation of BIFs.

% TODO: Allow caller to set pixel to start subsampling from.
% For asymmetric filters, or time filters (where the functional filter may be
% symmetric but not centred in the sampling window), a different centre  for
% resampling may produce a resampled filter that more accurately represents 
% the underlying function.

% If rolling average output is odd-sized in a given dimension the A and B
% centre bins will be the same. If the rolling aveage output is even-sized, the
% A and B centre bins will be different.
ctrColA = ceil((numCols+1)/2);
ctrColB = floor((numCols+1)/2);
if numDims == 2
    ctrRowA = ceil((numRows+1)/2);
    ctrRowB = floor((numRows+1)/2);
else
    ctrRowA = 1;
    ctrRowB = 1;
end

%% Subsample rolling average to generate downsampled filter
% Average the result of subsampling from all possible central bins to handle
% even-dimensioned rolling average output. If we don't do this we run the risk
% of producing asymmetric downsampled filters for symmetric input filters,
% especially where the output filter size is small.
outFilterAA = subsample(rollingAverage,scaleFactor,ctrColA,ctrRowA);
outFilterAB = subsample(rollingAverage,scaleFactor,ctrColA,ctrRowB);
outFilterBA = subsample(rollingAverage,scaleFactor,ctrColB,ctrRowA);
outFilterBB = subsample(rollingAverage,scaleFactor,ctrColB,ctrRowB);

outFilter = (outFilterAA + outFilterAB + outFilterBA + outFilterBB) / 4;

end % main function

function output = subsample(input, sampleStep, startCol, startRow)
    [numRows, numCols] = size(input);
    % Define front column indexes in reverse order to ensure that ctrCol is 
    % included
    sampleColumnIndexesFront = [startCol:-sampleStep:1];
    % Reverse column indexes to ensure downsampled filter has correct 
    % orientation
    sampleColumnIndexesFront = sampleColumnIndexesFront(end:-1:1);
    % Can define back column indexes with no reverse trick
    sampleColumnIndexesBack = [startCol+sampleStep:sampleStep:numCols];
    % Combine front and back parts to get full set of sample columns
    sampleColumnIndexes = [sampleColumnIndexesFront,sampleColumnIndexesBack];

    % Define front row indexes in reverse order to ensure that ctrRow is 
    % included
    sampleRowIndexesFront = [startRow:-sampleStep:1];
    % Reverse column indexes to ensure downsampled filter has correct 
    % orientation
    sampleRowIndexesFront = sampleRowIndexesFront(end:-1:1);
    % Can define back column indexes with no reverse trick
    sampleRowIndexesBack = [startRow+sampleStep:sampleStep:numRows];
    % Combine front and back parts to get full set of sample columns
    sampleRowIndexes = [sampleRowIndexesFront,sampleRowIndexesBack];

    % Sample bins defined by intersection of row and column indexes
    output = input(sampleRowIndexes,sampleColumnIndexes);
end % subsample