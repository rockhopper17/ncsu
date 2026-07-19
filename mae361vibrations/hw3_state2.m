function f = hw3_state2(x,t)
% function f = name_state(x,)
% this m-file lists the state equations
% inputs
%	x(t)	nx1 vector of state variables at time t
%	t		time
% outputs
%	f(x,t)	nx1 vector of time derivatives of state variables

% hw3 - system 1-2 - linearized state eqns for equi pt at pi

% system parameters
H = 4;			% in
R = 3;			% in
m = 15 / 32.2;	% lb s^2 / ft = slug
k = 15;			% lb / in
%c = 0.01;		% lb s / in
c = 0.5;		% lb s / in

f(1) = x(2);
f(2) = -64.4*x(1) - 0.2385*x(2) + 202.32;
