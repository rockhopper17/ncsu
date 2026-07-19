%%

function s = removeChar(c, s)
%removeChar removes the character c from the String s
%   Inputs: c - a single character to be removed
%           s - the string to be modified
%  Returns: s - the MODIFIED string

i=1;
while i<=length(s)
    length(s)
    if (s(i) == c)
        s(i)=[];
        i
        s
    else
        i=i+1        
    end       
end

%Solution 2
% newStr='';
% for i=1:length(s)
%     if (s(i) ~= c)
%         %concatenate if not a space
%         newStr = [newStr, s(i)];
%     end
% end
% s=newStr;    


