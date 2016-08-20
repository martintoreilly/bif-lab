function colourMap = mtBifColourMap()
%mtBifColourMap
% Generate colour map for use when displaying BIFs
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
% USAGE: colourMap = mtBifColourMap()

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
