close all; clear all; clc;

syms x n
%f = -2*x + 3;
%fseries = ((4*pi-6)*cos(pi*n)/(pi*n) + 6/(pi*n)) * sin(n*x);
f = x^3;
fseries = (12/n^3 - 2*pi^2/n)*cos(n*pi)*sin(n*x);

%xvals = linspace(0,pi);
xvals = linspace(-pi,pi);
plot(xvals,subs(f,x,xvals),'k--','DisplayName','exact');
hold on;

nmax = 51; % values: 4, 9, 51
fsum = symsum(fseries,n,1,nmax);
plot(xvals,subs(fsum,x,xvals),'b-','DisplayName',['n=' num2str(nmax)]);

xlabel('x');
ylabel('f(x)');
%xticks([0 pi/4 pi/2 3*pi/4 pi]);
%xticklabels({'0','\pi/4','\pi/2','3\pi/4','\pi'});
xticks([-pi -3*pi/4 -pi/2 -pi/4 0 pi/4 pi/2 3*pi/4 pi]);
xticklabels({'-\pi','-3\pi/4','-\pi/2','-\pi/4','0','\pi/4','\pi/2','3\pi/4','\pi'});
set(gca,'FontSize',16);
%legend('location','northeast');
legend('location','northwest');
