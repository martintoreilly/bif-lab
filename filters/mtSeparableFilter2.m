function output =  mtSeparableFilter2(xFilter, yFilter, input, mode)
%mtSeparableFilter2
% Performs 2D filtering of a 2D matrix input by a separable 2D filter by
% filtering by the x and y filter components in turn and combining the results
%
% INPUTS:
% xFilter: 1D filter comprising the x-component of a separable 2D filter
% yFilter: 1D filter comprising the y-component of a separable 2D filter
%   - Filters must be of odd length (and therefore have a centre pixel)
% input: The 2D input matrix to be filtered
% mode: The filter mode. Options are:
%   - 'cyclic': Returns an output the same size and the input. The input is 
%     extended in x and y prior to filtering, with the extended boundaries
%     filled with pixels "wrapped round" from the opposite edge of the input
%   - 'mirror': Returns an output the same size and the input. The input is 
%     extended in x and y, prior to filtering, with the extended boundaries
%     filled with pixels "reflected" from the edge of the input.
%   - Any valid "shape" argument to Matlab's built-in filter2 function. These
%     options will all extend the image in x and y prior to filtering, with the
%     extended boundaries filled with zeros. The "shape" argument determines
%     the size of the output. For more information type 'help filter2' at the 
%     command line.
%
% OUTPUTS:
% output: Filtered output (same size as input)
% 
% USAGE: output = mtSeparableFilter2(xFilter, yFilter, input, mode)

% Check x and y filters are 1D vectors
if length(xFilter)~=length(xFilter(:)) || length(yFilter)~=length(yFilter(:))
    error('x and y filters must be 1D vectors');
end
% check x and y filters have an odd length (therefore have a centre pixel)
if ~isequal(mod([length(xFilter),length(yFilter)],2),[1 1])
    error('x and y filters must be of odd length');
end

% Ensure x is a row vector and y is a column vector (we have already
% checked they are 1D vectors)
xFilter = reshape(xFilter(:),[1,length(xFilter)]);
yFilter = reshape(yFilter(:),[length(yFilter),1]);

if strcmpi(mode,'cyclic')
% If cyclic mode selected, extend image in x (for x filter pass) and y 
% (for y filter pass) and fill extended padding with pixels from opposite 
% side of image. Using filter2 in 'valid' mode on the padded image returns an 
% output with the same dimensions as the unpadded input image.
    xPad = (length(xFilter)-1)/2;
    yPad = (length(yFilter)-1)/2;
    xOut = filter2(xFilter,...
        [input(:,end-xPad+1:end),input,input(:,1:xPad)],'valid');
    output = filter2(yFilter,...
        [xOut(end-yPad+1:end,:);xOut;xOut(1:yPad,:)],'valid');
elseif strcmpi(mode,'mirror')
% If mirror mode selected, extend image in x (for x filter pass) and y 
% (for y filter pass) and fill extended padding with reflected boundary 
% pixels. Using filter2 in 'valid' mode on the padded image returns an output
% with the same dimensions as the unpadded input image.
    xPad = (length(xFilter)-1)/2;
    yPad = (length(yFilter)-1)/2;
    xOut = filter2(xFilter,...
        [input(:,xPad:-1:1),input,input(:,end:-1:end-xPad+1)],'valid');
    output = filter2(yFilter,....
        [xOut(yPad:-1:1,:);xOut;xOut(end:-1:end-yPad+1,:)],'valid');
else
% Otherwise just apply filter2 for x and y filters, passing selected mode
% Modes supported by filter2 are:
% 'same'  - (default) returns the central part of the 
%                 correlation that is the same size as the image.
% 'valid' - returns only those parts of the correlation
%                 that are computed without the zero-padded
%                 edges, size(output) < size(image).
% 'full'  - returns the full 2-D correlation, 
%                 size(output) > size(image).
    output = filter2(yFilter,filter2(xFilter,input,mode),mode);
end
