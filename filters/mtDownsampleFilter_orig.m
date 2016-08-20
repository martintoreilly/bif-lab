function outFilter = mtDownsampleFilter(inFilter, sampleSize, ctrPx)
%mtDownsampleFilter
% Downsamples 1D or 2D filters by averaging across sampleSize bins. Generating a
% discrete filter at a higher resultion than required and then downsampling to
% the required resolution can often help produce a more accurate filter 
% representation. This is especially true where filters will have a low
% resolution and it is important to preserve symmetry.
%
% INPUTS:
% sampleSize: Number of bins to average over and collapse into a single bin in 
%             the output filter%
% [ctrPx]: Optional vector specifying column and row indices of first point to
%          include in resampled filter. Order is [colIdx, rowIdx] as a 1d
%          filter will be a single row and ctrPx(1) must therefore be a column
%          index.
% OUTPUTS:
% outFilter: Downsampled filter
%
% USAGE: outFilter = mtDownsampleFilter(inFilter, sampleSize, ctrPx)

% Determine if inpout filter is 1D or 2D
if size(inFilter,1) == 1 || size(inFilter,2) == 1
    numDims = 1;
else
    numDims = 2;
end
% Generate 1D or 2D top-hat filter the size of
if numDims == 1;
    sampleFilter = ones(1,sampleSize);
else
    sampleFilter = ones(sampleSize,sampleSize);
end
% 
tempFwd = conv2(inFilter, sampleFilter, 'valid');
tempRev = conv2(inFilter(end:-1:1,end:-1:1), sampleFilter, 'valid');

% Default is to centre on centre of physical filter. This is appropriate for
% symmetric filters. However for asymmetric filters, or time filters (where the
% functional filter may be symmetric but not centred in the sampling window), 
% a different centre for resampling may produce a resampled filter that more 
% accurately represents the underlying function.
if nargin == 3
    ctrColFwd = ctrPx(1)-floor(sampleSize/2);
    ctrColRev = size(tempRev,2)-(ctrPx(1)-ceil(sampleSize/2));
    if numDims == 2
        ctrRowFwd = ctrPx(2)-floor(sampleSize/2);
        ctrRowRev = size(tempRev,2)-(ctrPx(2)-ceil(sampleSize/2));
    else
        ctrRowFwd = 1;
        ctrRowRev = 1;
    end
else
    ctrColFwd = ceil(size(tempFwd,2)/2);
    ctrColRev = size(tempRev,2)-(ceil(size(tempRev,2)/2));
    if numDims == 2
        ctrRowFwd = floor(size(tempFwd,1)/2);
        ctrRowRev = size(tempRev,2)-(ceil(size(tempRev,1)/2));
    else
        ctrRowFwd = 1;
        ctrRowRev = 1;        
    end
end

frontRowFwd = [ctrRowFwd-sampleSize:-sampleSize:1];
frontRowFwd = frontRowFwd(end:-1:1);
frontColFwd = [ctrColFwd-sampleSize:-sampleSize:1];
frontColFwd = frontColFwd(end:-1:1);
backRowFwd = [ctrRowFwd+sampleSize:sampleSize:size(tempFwd,1)];
backColFwd = [ctrColFwd+sampleSize:sampleSize:size(tempFwd,2)];
frontRowRev = [ctrRowRev-sampleSize:-sampleSize:1];
frontRowRev = frontRowRev(end:-1:1);
frontColRev = [ctrColRev-sampleSize:-sampleSize:1];
frontColRev = frontColRev(end:-1:1);
backRowRev = [ctrRowRev+sampleSize:sampleSize:size(tempRev,1)];
backColRev = [ctrColRev+sampleSize:sampleSize:size(tempRev,2)];

outFilter1 = tempFwd([frontRowFwd,ctrRowFwd,backRowFwd],...
    [frontColFwd,ctrColFwd,backColFwd]);
outFilter2 = tempRev([frontRowRev,ctrRowRev,backRowRev],...
    [frontColRev,ctrColRev,backColRev]);
outFilter2 = outFilter2(end:-1:1,end:-1:1);

outFilter = (outFilter1 + outFilter2) / (2 * sampleSize^numDims);