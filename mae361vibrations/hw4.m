% Andrew Navratil
% MAE 361 Fall 2018
% HW4
% Due 2018-10-01

% clear all vars and plots
close all; clear all; clc;

% setup plot
fig = figure(1);
colormap(jet) 
hold on;
grid on;
title('Angular position of bar vs time for hw4');
xlabel('time (s)');
ylabel('theta (deg)');

% integration variables
deltaT = .001;			% step size
N = 50/deltaT;			% num steps


% initial conditions for finding initial velocity and impulse force
% start the bar at rest at 89deg and see what the velocity is when it reaches 0deg (horizontal)
x(1) = 89 * (pi/180);
x(2) = 0;

x0pre = 0;
x0post = 0;
halftime = 0;
for i = 1:N
	t = (i-1)*deltaT;
	xnew = step2('hw4_state',x,t,deltaT);
	
	% set initial velocity when angle gets back to 0 and break loop
	if x0pre == 0 & xnew(1) <= 0
		x0pre = x;			% values just before it gets to horizontal
		x0post = xnew;		% values just after it gets to horizontal
		halftime = t;		% this will be half the time it takes to go up and back to horizontal
		break;
	end

	x = xnew;
end


% Runge-Kutte nonlinear
x(1) = 0;
%x(2) = -x0post(2);
%x(2) = 2.999;

% need to buffer this a little since we aren't exact, otherwise it doesn't stop at 89deg and just keeps going by
% so use the values calculated just before it stopped at 89deg
% must use negative of value since we calculated the velocity on it's way down but want it going up to start
x(2) = -x0pre(2);	

for i = 1:N
	t = (i-1)*deltaT;
	xnew = step2('hw4_state',x,t,deltaT);
	xgraph(i) = x(1);
	time(i) = t;
	x = xnew;
	
	%if x(1) >= (89*pi/180) break; end;
end

xgraph = xgraph * 180 / pi;
plot(time,xgraph);

