% Andrew Navratil
% 2017-11-30
% Section #205
% Homework 10

clear;close all;clc;

%% 1. interp1: specific volume of water

% temperatures range from 100 to 700 by 50
temps = 100:50:700;

% specific volume values per temp for P = 0.01 MPa
sv01 = [17.196 19.513 21.826 24.136 26.446 28.755 31.063 33.371 35.680 ...
		37.988 40.296 42.603 44.911];

% specific volume values per temp for P = 0.05 MPa
sv05 = [3.419 3.8897 4.3562 4.8206 5.284 5.7469 6.2094 6.6717 7.134 7.5957 ...
		8.0576 8.5195 8.9812];

% (looks like we only needed the values for 600 and 650 as linterp1 only looks
% at the two points around desired value for linear, but already typed them all in)

% perform linear interpolations to find values at:

% 615 deg for 0.01 MPa
sv01at615 = interp1(temps,sv01,615,'linear');

% 615 deg for 0.05 MPa
sv05at615 = interp1(temps,sv05,615,'linear');

% now for 615 deg at 0.03 MPa by interpolating between 0.01 and 0.05 values
% * this is the answer to what is the specific volume of water
%	at 0.03 MPa and 615 deg C
sv03at615 = interp1([0.01 0.05],[sv01at615 sv05at615],0.03);

%% 2. box with maximized volume 

% box has open top and square base (length = width)
% surface area (SA) = (width (w) ^2) + (4 * width (w) * height (h))
% volume (V) = length * width * height = width^2 * height
syms h w V;

% surface area set to 10 m^2
SA = 10;

% solve SA eqn for h
h = (SA - w^2) / (4 * w);

% setup volume eqn, h will be substituted leaving only w as variable
V = w^2 * h;

% find max volume by setting derivative to zero and solving for w
%    solve will return two values, take the max to get positive one
width = double(max(solve(diff(V) == 0)));

% now plug w back into h variable to get height
height = double(subs(h,width));

% plug w into V to get volume
volume = double(subs(V,width));

% print results to command window (recall length = width)
%     show values to 4 sig figs, no requirement specified here
fprintf('Maximized volume of box is %.4f m^2.\n',volume);
fprintf(['The dimensions of the box are: length = %.4f m, width = %.4f m, ' ...
	'height = %.4f m.\n'], width, width, height);

% answer gives vol = 3.0429, w = 1.8257 giving h = 0.9129
% try other widths to confirm we have max vol by substituting different values
% for width into the volume eqn:
%double(subs(V,1.5))
%double(subs(V,2))
%double(subs(V,1.8))
%double(subs(V,1.85))

%% 3. velocity to acceleration and position

% setup variables for velocity (v), time (t), acceleration (a) and position (s)
syms v t a s

% velocity equation
v = t.^3 + 10*t.^2 + 2*t + 3;

% differentiate to get acceleration
a = diff(v);

% integrate to get position (assume s = 0 at t = 0 giving constant of integration = 0)
s = int(v);

% plot each eqn together over 10 seconds
figure;

% time range
trange = [0 10];

% plot position first with a grid
% per piazza post, we don't need to use eval
% originally used ezplot as provided in lecture notes, however it is obsolete
% with fplot preferred
subplot(3,1,1);
fplot(s,trange);
grid on;
title('Position');

% plot velocity second with grid
subplot(3,1,2);
fplot(v,trange);
grid on;
title('Velocity');

% plot accelaration last with grid and include x label
subplot(3,1,3);
fplot(a,trange);
grid on;
title('Acceleration');
xlabel('Seconds (s)');

%% 4. solve systems of equations

% write part a equations as linear algebraic matrices
Aa = [-2 1; 1 1];
Ba = [3; 10];

% solve using left divide
Xa = Aa \ Ba;

% write part b equations as linear algebraic matrices
Ab = [5 3 -1; 3 2 1; 4 -1 3];
Bb = [10; 4; 12];

% solve using left divide
Xb = Ab \ Bb;

% write part c equations as linear algebraic matrices
Ac = [3 1 1 1; 1 -3 7 2; 2 2 -5 4; 1 1 1 1];
Bc = [24; 12; 17; 0];

% solve using left divide
Xc = Ac \ Bc;

