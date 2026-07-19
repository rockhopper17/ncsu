function f = hw5_state(x,t)
% function f = name_state(x,t)
% this m-file lists the state equations
% inputs
%	x(t)	nx1 vector of state variables at time t
%	t		time
% outputs
%	f(x,t)	nx1 vector of time derivatives of state variables

% hw5 n-link chain for 2, 3 links

% system parameters
n = 3;			% number of links
k = 1e5;		% spring stiffness

L(1:n) = 1;		% lengths of links [m]
m(1:n) = 1;		% mass of links [kg]
g = 9.81;		% gravity accel [m/s^2]

% the x (z in handoout) vector, holding x, y and their derivatives
% x(1) = x1, x(2) = y1, x(3) = x2, x(4) = y2, ...
% x(2n+1) = x1 dot, x(2n+2) = y1 dot, x(2n+3) = x2 dot, x(2n+4) = y2 dot, ...
% f holds the state equations, which are dot and double dot values

% get x values and y values, concat a 0 at beginning for origin
xvals = [0 x(1:2:2*n-1)];
yvals = [0 x(2:2:2*n)];

% first derivatives (x dot, y dot)
f(1:2*n) = x(2*n+1:4*n);

% length of link sqrt((delta x)^2 + (delta y)^2)
D = sqrt( (xvals(2:end) - xvals(1:end-1)).^2 + (yvals(2:end) - yvals(1:end-1)).^2 );

% change in length of link (for F=ks spring force)
s = D - L;

% unit vectors in x and y dir for link
ex = -(xvals(2:end) - xvals(1:end-1));
ey = -(yvals(2:end) - yvals(1:end-1));

% second derivatives (x double dot, y double dot)
%	concat 0 at end of s, e to handle the final link
f(2*n+1:2:4*n-1) = (1./m) .* ( k.*s.*ex - k.*[s(2:end) 0].*[ex(2:end) 0] );
f(2*n+2:2:4*n) = (1./m) .* ( k.*s.*ey - k.*[s(2:end) 0].*[ey(2:end) 0] ) + g;

