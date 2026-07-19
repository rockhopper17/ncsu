function [ newStr ] = convertToBlank( str )
% Replaces each instance of '_' (underscore) with ' ' (blank space)
%	Inputs: str - string with underscores
%	Outputs: newStr - string with blank spaces for underscores

% use strrep string func to replace '_' with ' '
newStr = strrep(str, '_', ' ');

end
