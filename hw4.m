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
x = reshape(pmesh(2:end,1).', [jmx,imx]).';
y = reshape(pmesh(2:end,2).', [jmx,imx]).';

% call c code
[imx,jmx,x,y,zx,zy,ex,ey,xj,u,v] = mesh();

% scatter plot the physical mesh to see it
scatter(reshape(x.',1,[]),reshape(y.',1,[]),'.');
%scatter(x,y,'.');
% todo plot i,j coords like horn maps
grid on;

% contourf
figure;
colormap('jet');
contourf(x,y,ex);
grid on;
colorbar;
figure;
colormap('jet');
contourf(x,y,ey);
grid on;
colorbar;

% phi analytical
figure;
colormap('jet');
phi = 10*x - 5*y;
contourf(x,y,phi);
grid on;
colorbar;
