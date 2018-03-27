% Andrew Navratil
% MAE 252 Aero I Spring 2018
% Project 1: Plot streamlines and velocity magnitudes for elementary function combos
% Due 2018-04-02

% clear all vars and plots
close all; clear all; clc;

%=====================================================================
% Rankine Half Oval
%=====================================================================

% variables
vInf = 50;				% freestream velocity (m/s)
lambda = 50;				% source / sink strenth
b = 2;					% distance between sources
x0 = 1;				% x center coord
y0 = .5;					% y center coord
D = [0];				% constants that psi is equal to - individual streamlines
xr = linspace(0,2,200);	% x points for grid
yr = linspace(0,1,100);	% y points for grid
[x,y] = meshgrid(xr,yr);

psiHalfOval = vInf * (y - y0) + (lambda / (2 * pi)) * atan2(y - y0, x - x0);
z = psiHalfOval;
z(abs(z) < (lambda / 2)) = 0;

figure;
contour(x,y,z,25);
pbaspect([2 1 1]);

