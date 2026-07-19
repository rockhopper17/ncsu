close all; clear all; clc;

syms x n t

% pblm 4
tarr = [0 .5 1 1.5 2 2.5 3];
for i = 1:7
	t = tarr(i)
	fseries = (9/(10*n*n*pi*pi))*sin(n*pi*x)*sin(n*pi/3)*cos(n*t);

	xvals = linspace(0,1);
	fsum = symsum(fseries,n,1,10);

	figure;
	plot(xvals,subs(fsum,x,xvals),'b-','DisplayName',['t=' num2str(t)]);
	xlabel('x');
	ylabel('u(x,t)');
	set(gca,'FontSize',16);
	legend('location','northeast');
end
