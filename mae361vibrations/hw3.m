% Andrew Navratil
% MAE 361 Fall 2018
% HW3
% Due 2018-09-24

% clear all vars and plots
close all; clear all; clc;

% setup plot to hold all four curves
fig = figure(1);
colormap(jet);  % macOS has different default, want jet
hold on;
grid on;
title('Angular position of spring vs time for system 1-2');
xlim([0 6.0]);
ylim([168 192]);
xlabel('time (s)');
ylabel('theta (deg)');

% analytic sln around neighborhood of equilibrium position (converted to degrees)
alpha = 0.1193;	% damping rate
wd = 8.02;		% damped frequency
f0 = @(t) ( exp(-alpha.*t) .* (0.1745 * cos(wd.*t) + 0.0026 * sin(wd.*t)) + pi) * 180 / pi;

fplot(f0,'k');

% calculate fundamental period from this analytic sln
wn = sqrt(wd^2 + alpha^2);
Tf = 1/wn;

% initial conditions for numerical integration methods
x1init = 3.3161;
x2init = 0;

deltaT = 0.005 * Tf;	% step size
N = 6/deltaT;			% num steps

% Euler nonlinear
x(1) = x1init;
x(2) = x2init;
for i = 1:N
	t = (i-1)*deltaT;
	xnew = step1('hw3_state',x,t,deltaT);
	xgraph(i) = x(1);
	time(i) = t;
	x = xnew;
end

xgraph = xgraph * 180 / pi;  % convert to degrees
plot(time,xgraph,'--r');

% Runge-Kutta nonlinear
x2(1) = x1init;
x2(2) = x2init;
for i = 1:N
	t2 = (i-1)*deltaT;
	xnew2 = step2('hw3_state',x2,t2,deltaT);
	xgraph2(i) = x2(1);
	time2(i) = t2;
	x2 = xnew2;
end

xgraph2 = xgraph2 * 180 / pi;  % convert to degrees
plot(time2,xgraph2,'-.b');

% Runge-Kutta linear
x3(1) = x1init;
x3(2) = x2init;
for i = 1:N
	t3 = (i-1)*deltaT;
	xnew3 = step2('hw3_state2',x3,t3,deltaT);
	xgraph3(i) = x3(1);
	time3(i) = t3;
	x3 = xnew3;
end

xgraph3 = xgraph3 * 180 / pi;  % convert to degrees
plot(time3,xgraph3,':k');

% legend info
legend('Analytical','Euler nonlinear','Runge-Kutta nonlinear','Runge-Kutta linear','location','southeast');
