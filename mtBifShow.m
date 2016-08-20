function imHandle = mtBifShow(bifs)
%mtBifShow
% Display BIFs with same colour scheme as in Crosier and Griffin BIF journal 
% papers. Elements with invalid BIF classes will be displayed as cyan.
% Pink: flat (class 1)
% Grey: gradient (class 2)
% Black: dark blob (class 3)
% White: light blob (class 4)
% Blue: dark line (class 5)
% Yellow: light line (class 6)
% Green: saddle (class 7)
% 
% INPUTS:
% bifs: 2D matrix of BIF classes (elements in range 1..7)
%
% OUTPUTS:
% imHandle: Handle to the figure in which the BIFs have been displayed
%
% USAGE: h = mtBifShow(bifs)

% Set BIF class colour map
bifMap = mtBifColourMap();

% Set all elements with invalid BIF classes to 0, as this has a defined clour
% mapping
minValidBifClass = 1;
maxValidBifClass = 7;
bifs(bifs<minValidBifClass | bifs>maxValidBifClass) = 0;

% Show bif classes with colour map
imHandle = mtImShow(uint8(bifs),bifMap);
