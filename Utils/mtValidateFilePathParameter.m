function mtValidateFilePathParameter(param, rootDir)
%mtValidateFilePathParameter
% Validates that a parameter is valid path to an existing file and throws an 
% error if it is not.
%
% USAGE: mtValidateFilePathParameter(param)

paramName = inputname(1);

% Ensure parameter is non-empty string (prerequisite to be a filepath)
if(isempty(param))
    error([paramName,' is empty.']);
end
if(~ischar(param))
    error([paramName,' is not a string. Value: ', param]);
end

% Ensure parameter is a full file path. The built-in exist() function checks 
% every directory in the Matlab path if a full path is not provided.
% If root directory provided, prepend this. Otherwise, prepend current working
% directory.
if(nargin < 2)
    rootDir = pwd();
end
[directoryPath,filename,fileExtension] = fileparts(param);
if(isempty(directoryPath))
    filePath = fullfile(rootDir,[filename,fileExtension]);
else
    filePath = param;
end

% Check if file exists at given path
if(~exist(filePath, 'file'))
    error([paramName,' is not a file. Value: ', filePath]);    
end