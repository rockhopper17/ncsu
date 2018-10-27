function f = final_state(x,t)
% function f = name_state(x,t)
% this m-file lists the state equations
% inputs
%	x(t)	nx1 vector of state variables at time t
%	t		time
% outputs
%	f(x,t)	nx1 vector of time derivatives of state variables

% final project - planar n-body problem

% globals values in main file
global n m

% system parameters
%n = 3;              % number of orbital bodies
G = 6.67259e-20;      % universal gravitational constant [km^3/kg/s^2]

% the x vector holds x, y positions of each body and their velocities (derivatives)
% x(1) = x1, x(2) = y1, x(3) = x2, x(4) = y2, ...
% x(2n+1) = x1 dot, x(2n+2) = y1 dot, x(2n+3) = x2 dot, x(2n+4) = y2 dot, ...
% f holds the state equations, which are dot and double dot values

% get x values and y values
xvals = x(1:2:2*n-1);
yvals = x(2:2:2*n);

% velocity / first derivatives (x dot, y dot)
f(1:2*n) = x(2*n+1:4*n);

% distance between bodies and corresponding unit vectors
% r(i,j) = distance from ith body to jth body
% ex(i,j) or ey(i,j) = unit vector for x,y dir from ith body to jth body
% todo: optimize this code to remove repeated calculations and unit vectors
r = zeros(n,n);
ex = zeros(n,n);
ey = zeros(n,n);
for i = 1:n
	r(i,1:end) = sqrt( (xvals(i) - xvals(1:end)).^2 + (yvals(i) - yvals(1:end)).^2 );
	ex(i,1:end) = (xvals(1:end) - xvals(i)) ./ r(i,:);
	ey(i,1:end) = (yvals(1:end) - yvals(i)) ./ r(i,:);
end

% set all NaN values to zero for calculations below
ex(isnan(ex)) = 0;
ey(isnan(ey)) = 0;

% acceleration / second derivatives (x double dot, y double dot)
%   note: unit vector value of 0 for ith-ith (same body) will take care of
%		the acceleration value of a body relative to itself
%		but still must use omitnan for sum function
for i = 1:n
	f(2*n+(2*i-1)) = sum(G.*m.*ex(i,1:end)./r(i,1:end).^2,'omitnan');
	f(2*n+(2*i)) = sum(G.*m.*ey(i,1:end)./r(i,1:end).^2,'omitnan');
end

