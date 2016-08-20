function install(permanentFlag)
%install
% Adds BifLab folder and subfolders to Matlab path, either for current session
% (permanentFlag = false) or permanently (permanentFlag = true)
%
% INPUTS:
% [permanentFlag]: Optional flag to determine if altered path is saved once 
%                  BifLab folders have been added to it. If FALSE folders are
%                  added to path just for current session. If TRUE folders are
%                  added to path permanently. Default is TRUE.
% 
% USAGE: install(permanentFlag)

% Set permanent flag to default if not supplied
if(nargin < 1)
    permanentFlag = true;
end

% Add top-level BifLab folder (where this script is called from)
baseDir = pwd;
addpath(baseDir);

% Explicitly add subfolders to avoid adding hidden folders such as .git
addpath(fullfile(baseDir, 'filters'));
addpath(fullfile(baseDir, 'tests'));
addpath(fullfile(baseDir, 'utils'));

if(permanentFlag)
    savepath();
end
