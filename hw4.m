% Andrew Navratil
% MAE 456 CFD
% HW4: Metric Derivatives
% Due 2019-04-10

% clear all vars and plots
close all; clear all; clc;

% read in physical mesh, first row holds imx,jmx
pmesh = load('grid-poisson-2015.txt');
imx = pmesh(1,1);
jmx = pmesh(1,2);
x = reshape(pmesh(2:end,1), [imx,jmx]);
y = reshape(pmesh(2:end,2), [imx,jmx]);

% scatter plot the physical mesh to see it
scatter(pmesh(2:end,1),pmesh(2:end,2),'.');
% todo plot i,j coords like horn maps
grid on;

% call c code
[zx,zy,ex,ey,xj] = mesh(imx,jmx,x,y);
