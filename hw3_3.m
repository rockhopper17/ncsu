close all; clear all; clc;

d = readmatrix(['hw3data/slndata_3.dat']);
%d = readmatrix(['hw3data/slndata_3_init.dat']);

n = 10;
gridlen = 1.0;
dval = 0.005;
h = gridlen/n;
x = d(:,3);
y = d(:,4);
u = d(:,5);

xv = linspace(min(x), max(x), 100);
yv = linspace(min(y), max(y), 100);
[X,Y] = meshgrid(xv, yv);
Z = griddata(x,y,u,X,Y);

%surf(X,Y,Z);
contourf(X,Y,Z);
c = colorbar;
c.Label.String = 'T(x,y)';
grid on;
xlabel('x');
ylabel('y');
set(gca,'FontSize',16);

