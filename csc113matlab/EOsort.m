% Andrew Navratil
% 2017-11-09
% Section #205
% Homework 8

function [scell, varargout] = EOsort(vec)
% Sorts a row vector into even and odd values, with an optional timing for second output
% Input:	vec is a row vector of numbers	
% Output:	scell is a 1x2 cell array, with the first cell being an array of even numbers
%				and the second cell being an array of odd numbers from vec
%			varargout is a single optional timing parameter

if nargout == 2
	% if the optional output for timing is present, start the clock
	tic;
end

% sort using logical indexing (supposed to be more efficient than find, timing was pretty similar)
scell{1} = vec(rem(vec,2) == 0); % evens
scell{2} = vec(rem(vec,2) ~= 0); % odds

if nargout == 2
	% stop the clock and save to varargout
	varargout{1} = toc;
end

end
