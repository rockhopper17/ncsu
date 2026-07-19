function c = stumpC(z)
% ˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜
%
% This function evaluates the Stumpff function C(z) according
% to Equation 3.50.
%
% z - input argument
% c - value of C(z)
%
% ------------------------------------------------------------
if z > 0
c = (1 - cos(sqrt(z)))/z;
elseif z < 0
c = (cosh(sqrt(-z)) - 1)/(-z);
else
c = 1/2;
end
end