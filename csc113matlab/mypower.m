% Andrew Navratil
% 2017-11-09
% Section #205
% Homework 8

function aton = mypower( a, n)
% Recursively calculates the value of a raised to the n power without using ^
% Input:	a is an integer
%			n is a non-negative integer
% Output:	aton is the value of a raised to the n power

if n == 0
	% rule for raising a to the 0 power
	aton = 1;
elseif n == 1
	% base case for recursion
	aton = a;
else
	% recursive call to mypower to keep multiplying a n times
	aton = a * mypower(a, n-1);	
end

end
