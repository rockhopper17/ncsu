%%
function [str, nCaps] = capitalizeWords(str)
% capitalizeWords capitalizea 1st letter of each word in a phrase.
% Input: 
%   str= string with letters and spaces only
% Returns:
%   str= the string modified with each word capitalized
%   nCaps= no. of capital letters 

nCaps= 0; %initialize the count of capitalizations
%for the first word, check if it starts with a letter
if (isletter(str(1)))
   %capitalize that letter
   str(1)= upper(str(1)); 
   %count it 
   nCaps= nCaps + 1;
end

%for the rest of the words
for k= 2:length(str)
   %if space followed by letter
   if (str(k-1)==' ' && isletter(str(k)))
      %capitalize
      str(k)= upper(str(k)); 
      %count it 
      nCaps= nCaps + 1;
   end
end


