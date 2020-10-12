close all; clear all; clc;

d = readmatrix(['hw3data/slndata_3.dat']);

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
caxis([0 1.0]);
%xlim([0.35 0.65]);
%ylim([0.35 0.65]);
xlabel('x');
ylabel('y');
set(gca,'FontSize',16);
set(gcf, 'Position',  [500, 500, 1000, 800])

