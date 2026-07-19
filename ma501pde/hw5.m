close all; clear all; clc;

syms x n

% pblm1: maps to function inc convergence pts
%f = piecewise(-pi/2 < x < pi/2, 1, 0);
%fseries = (2/(n*pi))*sin(n*pi/2)*cos(n*x);
%a0 = 0.5;

% pblm2
%f = piecewise(0 <= x < pi, -x, 0);
%fseries = (-sin(n*pi)/n + ((-1)^(n-1)+1)/(pi*n*n))*cos(n*x) + ((-1)^n)*sin(n*x)/n;
%a0 = -pi/4;

% pblm3
%f = piecewise(0 < x < pi, 1/2, -pi < x < 0, -1/2);
%fseries = 2*sin((2*n-1)*x)/((2*n-1)*pi);
%a0 = 0;

% pblm4
f = cos(x);
fseries = (2/pi)*(4*n/(4*n*n-1))*sin(2*n*x);
a0 = 0;

% pblm5
%f = cos(4*x);

%xvals = linspace(-pi,pi); % pblm1,2
%fplot(f,[-pi pi],'k--','DisplayName','exact');
xvals = linspace(0,pi/2); % pblm4
fplot(f,[0 pi/2],'k--','DisplayName','exact');
hold on;

nmax = 72; % change value as desired, or pblm4 = 12*6(Andrew)=72
fsum = symsum(fseries,n,1,nmax);
plot(xvals,a0+subs(fsum,x,xvals),'b-','DisplayName',['n=' num2str(nmax)]);

% check convergence
%a0 + subs(fsum,x,[-pi -pi/2 0 pi/2 pi]) % pblm1: ~0 at -pi,pi; ~1 at 0; =1/2 at pi/2's
%a0 + subs(fsum,x,[-pi 0 pi]) % pblm2: ~-pi/2 (-1.556337..) and ~0 (-0.0144..)

xlabel('x');
ylabel('f(x)');
xticks([-pi -3*pi/4 -pi/2 -pi/4 0 pi/4 pi/2 3*pi/4 pi]);
xticklabels({'-\pi','-3\pi/4','-\pi/2','-\pi/4','0','\pi/4','\pi/2','3\pi/4','\pi'});
%ylim([-5*pi/4 pi/4]); % pblm2
%yticks([-5*pi/4 -pi -3*pi/4 -pi/2 -pi/4 0 pi/4])
%yticklabels({'-5\pi/4','-\pi','-3\pi/4','-\pi/2','-\pi/4','0','\pi/4'});
set(gca,'FontSize',16);
legend('location','northeast');
