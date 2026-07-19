function [ newVal ] = typeConvert( val )
% Converts a given value to different data types and concatenates the values
%	into a cell array.
%	Inputs: val - value of unknown data type
%	Outputs: newVal - cell array of different data types

d = double(val);
ui8 = uint8(val);     % unsigned integer 8
i16 = int16(val);     % signed integer 16
asciival = char(val); % ascii char
str = string(val);  % val as a string (not ascii character)
logic = logical(val);  % returns true if non-zero

newVal = {d, ui8, i16; asciival, str, logic};  % concatenate into cell array

end
