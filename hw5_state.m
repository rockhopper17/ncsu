function f = hw5_state(x,t)
% function f = name_state(x,t)
% this m-file lists the state equations
% inputs
%	x(t)	nx1 vector of state variables at time t
%	t		time
% outputs
%	f(x,t)	nx1 vector of time derivatives of state variables

% hw5_n2 - 2 link chain

% system parameters
L(1:2) = 1;		% lengths of links [m]
m(1:2) = 1;		% mass of links [kg]
g = 9.81;		% gravity accel [m/s^2]
k = 1e4;		% spring stiffness

% links in chain
% n = 2

% the z vector, holding x, y and their derivatives
% x(1) = x1, x(2) = y1, x(3) = x2, x(4) = y2
% x(5) = x1 dot, x(6) = y1 dot, x(7) = x2 dot, x(8) = y2 dot
% (f holds the state equations, which are dot and double dot values)

% first derivatives (x dot, y dot)
f(1) = x(5);
f(2) = x(6);
f(3) = x(7);
f(4) = x(8);

% length of link sqrt((delta x)^2 + (delta y)^2)
D1 = sqrt( x(1)^2 + x(2)^2 );	
D2 = sqrt( (x(3) - x(1))^2 + (x(4) - x(2))^2 );	

% change in length of link (for F=ks spring force)
s1 = D1 - L(1);
s2 = D2 - L(2);

% unit vectors in x and y dir for link
e1x = -x(1) / D1;
e1y = -x(2) / D1;
e2x = -(x(3) - x(1)) / D2;
e2y = -(x(4) - x(2)) / D2;

% second derivatives (x double dot, y double dot)
f(5) = (1/m(1)) * ( k*s1*e1x - k*s2*e2x );
f(6) = (1/m(1)) * ( k*s1*e1y - k*s2*e2y ) + g;
f(7) = (1/m(2)) * ( k*s2*e2x );
f(8) = (1/m(2)) * ( k*s2*e2y ) + g;

