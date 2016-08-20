function imHandle = mtImShow(im,cmap,flip,xRange,yRange,dataAspectRatio)
% USAGE: imHandle = mtImshow(im, cmap, flip, xRange, yRange, dataAspectRatio)
% Replacement for imshow. Does not permit the setting of the full range of 
% options that imshow allows. Also fixes what appears to be a bug in the mapping
% of indexed image values to the colour map for uint32 and uint64 indexed images
% immshow/image maps 0..n-1 to colormap of size n (i.e. colour
% of pixel is colourMap(pxVal+1,:). imshow maps 1..n to colourmap of size n 
% (i.e. colour of pixel is colourMap(pxVal,:). The 0..n-1 mapping seems more 
% appropriate. Note that the ind2rgb function also uses the 0..n-1 mapping.

% If colormap supplied...
if nargin > 1
    % set colormap
    set(gcf,'Colormap',cmap); 
end

% Display image in current axis
if nargin < 4
    % No range for data supplied so no axes
    hIm = image(im);
    % Remove axes tick marks and labels
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
else
    hIm = image(xRange,yRange,im);
    % Set ticks to be outside of image
    set(gca,'TickDir','out');
end

if size(im,3) == 1
    % Built-in behaviour for image() seems to be that the image CData is mapped
    % CData 1..n -> Colour map indices 1..n (as per documentation) for indexed
    % images of class uint32 and uint64. However, for indexed images of class
    % uint8 or uint16, it seems CData is mapped CData 0..n-1 -> Colour map 
    % indices 1..n (as desired here and as done by ind2rgb).
    % Therefore, if indexed image of class uint32 or uint64 supplied, set CData 
    % to image values + 1.
    im = uint64(im);
    if size(im,3) == 1
%         set(hIm,'CData',im+1);
        % Set custom datatip function to display correct index as originally
        % supplied in 'im'
        hDcm = datacursormode(gcf);
%         set(hDcm,'UpdateFcn',@mtImshow_dataTipFn)
    end
end

if nargin < 3
    flip = 1;
end
if flip == 1
    % Reverse Y axis so image displays right way up
    set(gca,'YDir','reverse');
else
    % Keep Y axis normal (used to graph heat map plots)
    set(gca,'YDir','normal');
end

% % Set plot box to square aspect ratio (makes pixels square but doesn't make
% % axis square if image is not)
if nargin < 6
    set(gca,'DataAspectRatio',[1 1 1]);
elseif ~strcmp(dataAspectRatio,'auto')
    set(gca,'DataAspectRatio',dataAspectRatio);
end

if nargout > 0
    imHandle = hIm;
end

% Custom datatip function to handle the mismatch between CData and supplied
% image data required to map 0..n-1 to colourmap indices 1..n for indexed images
% of class uint32 or uint64
function txt = mtImshow_dataTipFn(~,eventObj)
posXY = get(eventObj,'Position');
hIm = get(eventObj,'Target');
cData = get(hIm,'CData');
colMap = get(gcf,'ColorMap');
pxCdata = cData(posXY(2),posXY(1));
pxRGB = colMap(min(pxCdata,size(colMap,1)),:);
pxVal = pxCdata - 1;
txt = {['X: ',num2str(posXY(1)),'; Y: ',num2str(posXY(2))],...
    ['Index: ',num2str(pxVal)],['RGB: ',mat2str(mtImshow_roundsd(pxRGB,3))]};

% Embed François Beauducel's method for rounding to significant digits (used for
% dispaying RGB values in datatip). Embedded to permit mtImshow to be
% independent of other matlab files. Embedding permitted by BSD licence.
function y = mtImshow_roundsd(x,n,method)
%ROUNDSD Round with fixed significant digits
%	ROUNDSD(X,N) rounds the elements of X towards the nearest number with
%	N significant digits.
%
%	ROUNDS(X,N,METHOD) uses following methods for rounding:
%		'round' - nearest (default)
%		'floor' - towards minus infinity
%		'ceil'  - towards infinity
%		'fix'   - towards zero
%
%	Examples:
%		roundsd(0.012345,3) returns 0.0123
%		roundsd(12345,2) returns 12000
%		roundsd(12.345,4,'ceil') returns 12.35
%
%	See also Matlab's function ROUND.
%
%	Author: François Beauducel <beauducel@ipgp.fr>
%	  Institut de Physique du Globe de Paris
%	Acknowledgments: Edward Zechmann, Daniel Armyr
%	Created: 2009-01-16
%	Updated: 2010-03-17

% Copyright notice, conditions and disclaimer included as required by BSD
% licence
%	Copyright (c) 2010, François Beauducel, covered by BSD License.
%	All rights reserved.
%
%	Redistribution and use in source and binary forms, with or without 
%	modification, are permitted provided that the following conditions are 
%	met:
%
%	   * Redistributions of source code must retain the above copyright 
%	     notice, this list of conditions and the following disclaimer.
%	   * Redistributions in binary form must reproduce the above copyright 
%	     notice, this list of conditions and the following disclaimer in 
%	     the documentation and/or other materials provided with the distribution
%	                           
%	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%	POSSIBILITY OF SUCH DAMAGE.

error(nargchk(2,3,nargin))

if ~isnumeric(x)
		error('X argument must be numeric.')
end

if ~isnumeric(n) | numel(n) ~= 1 | n < 0 | mod(n,1) ~= 0
	error('N argument must be a scalar positive integer.')
end

opt = {'round','floor','ceil','fix'};

if nargin < 3
	method = opt{1};
else
	if ~ischar(method) | ~ismember(opt,method)
		error('METHOD argument is invalid.')
	end
end

og = 10.^(floor(log10(abs(x)) - n + 1));
y = feval(method,x./og).*og;
y(find(x==0)) = 0;

