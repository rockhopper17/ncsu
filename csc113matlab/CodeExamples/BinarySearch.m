%%

function [f varargout] = BinarySearch(vec, key)
% BinarySearch implements binary search
%   Input: vec is a the vector to search through
%          key is the value to search for
% Returns: f is the index of first occurrence of value x in vector V 
%          or f is -1 if x not found. 
low = 1;
high = length(vec);
f = -1;
C=0; 
while low <= high && f == -1 
   C = C+1;
   mid = floor((low + high)/2);
   if vec(mid) == key
       f = mid;
   elseif key < vec(mid)
       high = mid - 1;
   else
       low = mid + 1;
   end
   
end
varargout{1}=C;
end
