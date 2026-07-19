%%

function [f, varargout] =  LinearSearch(V, x)
% Linear Search
% Input: V is the vector to search through
%        x the value to search for         
% Returns: f is the index of first occurrence of value x in vector V 
%          or f is -1 if x not found.
k= 1;
C=1;
while k<=length(V) && V(k)~=x
    k= k + 1;
    C=C+1;
end

if k>length(V)
    f= -1; % signal for x not found
else
    f= k;
end

varargout{1}=C;

end