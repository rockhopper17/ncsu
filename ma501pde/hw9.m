close all; clear all; clc;

syms r theta n t

% pblm 2
fseries = -20*n*r.^(2*n-1) * sin((2*n-1).*theta) / (pi*3^(2*n-1))

thetavals = linspace(0,2*pi);
rvals = linspace(0,3);
fsum = symsum(fseries,n,1,100);
u = subs(fsum,{theta,r},{thetavals,rvals});

xv = linspace(min(thetavals), max(thetavals), 100);
yv = linspace(min(rvals), max(rvals), 100);
[X,Y] = meshgrid(xv, yv);
Z = griddata(thetavals,rvals,u,X,Y);

figure;
%plot(thetavals,subs(fsum,theta,xvals),'b-','DisplayName',['t=' num2str(t)]);
contour(X,Y,Z);
%xlabel('x');
%ylabel('u(x,t)');
set(gca,'FontSize',16);
%legend('location','northeast');
