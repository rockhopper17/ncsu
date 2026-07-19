function [ b ] = isPal( str )
% test to see if an input string is a palindrome 
%	Input: str - input string 
%	Output: b - boolean true of str is a palindrome, false if not	

% remove all blank spaces from string
str = strrep(str,' ','');

% convert the string to all lower case
str = lower(str);

% compare original string to reveresed string
b = strcmp(str,reverse(str));

end
