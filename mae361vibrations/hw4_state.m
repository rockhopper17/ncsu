function f = hw4_state(x,t)
% function f = name_state(x,)
% this m-file lists the state equations
% inputs
%	x(t)	nx1 vector of state variables at time t
%	t		time
% outputs
%	f(x,t)	nx1 vector of time derivatives of state variables

% hw4 - bar with impulse

% system parameters
L = 2;		% bar length [m]
m = 10;		% bar mass [kg]
F = 15;		% F force [N]

f(1) = x(2);
f(2) = ( (-6*F) / (m*L) ) * cos(x(1));
