% Name Andrew Navratil
% Date 2017-11-16
% Section #205
% In-Lab 10

clear all; close all; clc % clear functions

%% Instructor-Guided Portion
%% Problem 1 - Snow Plotting
% Import the data file and predict the snow accumulation.

% Load snowd.dat imported from Moodle:
snowd = load('snowd.dat');

% a. Fit a quadratic curve to the data:
weeks = 1:length(snowd);
quad = polyfit(weeks,snowd,2);

% b. Predict when the snow will completely disappear:
snowgone = ceil(max(roots(quad)));

% c. Co-plot the snow data and the quadratic curve:
figure(1);
hold on;

% Plot the snow data:
p1 = plot(weeks,snowd);

% Plot the quadratic curve:
xval = 1:snowgone;
yval = polyval(quad,xval);
p2 = plot(xval,yval);

% Set plot properties:
set(gca,'Color','black');
set(p1,'LineStyle','none','Marker','o','Color','white');
set(p2,'Color','b');
xlim([0 snowgone]);
ylim([0 max(snowd)]);
title(sprintf('Snow Gone in Week %d',snowgone));
xlabel('Week #');
ylabel('Snow Depth (in)');

%% Problem 2 - Enthalpy
% Solve for the change in enthalpy of oxygen.

% Set variable T as symbolic:
syms T;

% Assign variable constants given in problem:
a = 25.48;
b = 1.523*10^-2;
c = -0.716*10^-5;
d = 1.312*10^-9;
T1 = 300;  % lower bound: Kelvin
T2 = 1000; % upper bound: Kelvin

% Use the given integral to find change in enthalpy:
eqn = a + b*T + c*T^2 + d*T^3;  % eqn for change in enthalpy
deltaH = int(eqn,T1,T2);

%% Problem 3 - Quadratic Formula
% Create a symbolic expression for the quadratic equation and solve.

% Create symbolized variables:
syms a b c x;

% Write equation using symbolized variables:
f = a*x^2 + b*x + c;

% Solve using the quadratic equation and display:
quadform = solve(f,x);
pretty(quadform);

% Substitute given constants into equation and solve using subs():
aC = 1/21;
bC = 46;
cC = -2016;
xsol = subs(quadform,{a b c},[aC bC cC]);

%% Problem 4 - Matrix Math
% Write the system of equations as matrices and solve for x, y, and z.

% Re-write as matrices (AX=B):
A = [2 7 1; 2 0 3; 4 1 3];
B = [2;1;3];

% a. Find the inverse and determinant of A:
invA = inv(A);
detA = det(A);

% b. Solve for unknowns using left divide (A\B):
Xb = A\B;

% c. Solve for unknowns using inverse matrix multiplcation (A-1*B):
Xc = inv(A)*B;

%% Independent Portion

