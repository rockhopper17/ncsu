function f = hw6_state(x,t)
% function f = name_state(x,t)
% this m-file lists the state equations
% inputs
%	x(t)	nx1 vector of state variables at time t
%	t		time
% outputs
%	f(x,t)	nx1 vector of time derivatives of state variables

% system parameters
%k1 = 2.2;		% N/m
%k2 = 1.2;		% N/m
%k3 = 0.4;		% N/m
%L = 1;	% m
%mb = 1;  % kg
%mr = 3;  % kg
%F = 5;  % N (constant force)

% x(1) = theta val for mr; x(2) = x val for mb

% first derivatives (theta dot, x dot)
f(1:2) = x(3:4);

% second derivatives (x double dot, y double dot)
%f(3) = (3 / (mr * L^2)) * ( -k1*L^2 );
f(3) = -3.4*x(1) + 1.2*x(2);
f(4) = 1.2*x(1) - 1.6*x(2) + 5;

