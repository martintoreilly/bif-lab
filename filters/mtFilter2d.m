function output =  mtFilter2d(xyFilter, input, mode, method)
%mtFilter2d
% Performs 2D filtering of a 2D matrix input by a 2D filter
%
% INPUTS:
% xyFilter: 2D filter. Filter must be of odd size in both dimensions (and
%           therefore have a centre pixel)
% input: The 2D input matrix to be filtered
% mode: The filter mode. Options are:
%   - 'cyclic': Returns an output the same size and the input. The input is 
%     extended in x and y prior to filtering, with the extended boundaries
%     filled with pixels "wrapped round" from the opposite edge of the input
%   - 'mirror': Returns an output the same size as the input. The input is 
%     extended in x and y, prior to filtering, with the extended boundaries
%     filled with pixels "reflected" from the edge of the input.
%   - 'valid': Performs a 'valid' filter operation (i.e. no filtered values
%     for border pixels, but returns an output the same size as the input by 
%     padding the valid output with NaN
% [method]: Method to use to perform filtering operation. Optional. If not
%           provided, defaults to 'conv2'
%   - 'conv2': use built-in Matlab conv2 method (conv2 is faster than filter2
%     in some older MATLAB versions on multicore machines)
%   - 'convolve2': Use third part convolve2 function from 
%     http://www.mathworks.com/matlabcentral/fileexchange/22619
%   - 'convnfft': Use third party convnfft function from
%     http://www.mathworks.com/matlabcentral/fileexchange/24504
%
% OUTPUTS:
% output: Filtered output. Same size as input.
% 
% USAGE: output = mtFilter2d(xyFilter, input, mode, method)

if nargin < 4
    method = 'conv2';
end

[height,width]=size(xyFilter);
% check filter is odd in both dimensions (therefore has a centre pixel)
if ~isequal(mod([width,height],2),[1 1])
    error('filter must have dimensions of odd length');
end

xPad = (width-1)/2;
yPad = (height-1)/2;
rawMode = 'valid';
postPadNans = 0; % Used for 'padded' mode
%% If custom mode, amend image and mode then apply filter2/conv2
if strcmpi(mode,'cyclic')
% If cyclic mode selected, extend image in x and y and fill extended padding 
% with pixels from opposite side of image. Using filter2 in 'valid' mode on the 
% padded image returns an output with the same dimensions as the unpadded input 
% image.
    input = [input(:,end-xPad+1:end),input,input(:,1:xPad)];
    input = [input(end-yPad+1:end,:);input;input(1:yPad,:)];
elseif strcmpi(mode,'mirror')
% If mirror mode selected, extend image in x and y  and fill extended padding 
% with reflected boundary pixels. Using filter2 in 'valid' mode on the padded 
% image returns an output with the same dimensions as the unpadded input image.
    input = [input(:,xPad:-1:1),input,input(:,end:-1:end-xPad+1)];
    input = [input(yPad:-1:1,:);input;input(end:-1:end-yPad+1,:)];
elseif strcmpi(mode,'padded')
    postPadNans = 1;
end

% Perform correlation by flipping filter and doing convolution
% (I think conv2 is faster in some older MATLAB versions on multicore machines)
switch method
    case 'conv2'
        output = conv2(double(input),double(xyFilter(end:-1:1,end:-1:1)),...
            rawMode);
    case 'convolve2'
        if exist('convolve2','file') == 2
            output = convolve2(input,xyFilter(end:-1:1,end:-1:1),rawMode);
        else
            warning(['convolve2 not present, using built-in conv2 instead. ',...
                'convolve2 can be downloaded from ',...
                'http://www.mathworks.com/matlabcentral/fileexchange/22619']);
            output = conv2(double(input),double(xyFilter(end:-1:1,end:-1:1)),...
                rawMode);
        end
    case 'convnfft'
        if (exist('convnfft','file') == 2) && (exist('inplaceprod','file') == 3)
            output = convnfft(input,xyFilter(end:-1:1,end:-1:1),rawMode);
        elseif exist('convnfft','file') ~= 2
            warning(['convnfft not present, using buit-in conv2 instead. ',...
                'convnfft can be downloaded from ',...
                'http://www.mathworks.com/matlabcentral/fileexchange/24504']);
            output = conv2(double(input),double(xyFilter(end:-1:1,end:-1:1)),...
                rawMode);
        elseif exist('inplaceprod','file') ~= 3
            warning(['convnfft present but not installed, using buit-in ',...
                'conv2 instead. Install convnfft by running ',...
                'convnfft_install from the directory containing convnfft.m ',...
                'inplaceprod.c']);
            output = conv2(double(input),double(xyFilter(end:-1:1,end:-1:1)),...
                rawMode);
        end
    otherwise
        error('Invalid method argument.')
end
if postPadNans
    xPadStrip = NaN([size(output,1),xPad]);
    output = [xPadStrip,output,xPadStrip];
    yPadStrip = NaN([yPad,size(output,2)]);
    output = [yPadStrip;output;yPadStrip];
end

