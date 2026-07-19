%%
function [numChars, varargout] = countCharacters(S)
%Counts the characters in S
%returns the total number and the number of spaces

numChars=length(S);

if nargout == 2
    varargout{1} = length( find (S == ' '));
end



% function [varargout] = countCharacters(S)
% Counts the characters in S
% returns the total number and the number of spaces
% 
% varargout{1}=length(S);
% 
% if nargout == 2
%     varargout{2} = length( find (S == ' '));
% end





