close all; clear all; clc;

%pblm = 2
%d = readmatrix(['hw4data/ss_laplace_11.txt']);
%d2 = readmatrix(['hw4data/jacobi_11_res.txt']);
%d3 = readmatrix(['hw4data/gs_11_res.txt']);
%d4 = readmatrix(['hw4data/sor_11_res.txt']);
%d = readmatrix(['hw4data/ss_laplace_21.txt']);
%d2 = readmatrix(['hw4data/jacobi_21_res.txt']);
%d3 = readmatrix(['hw4data/gs_21_res.txt']);
%d4 = readmatrix(['hw4data/sor_21_res.txt']);

pblm = 3
d = readmatrix(['hw4data/ss_poisson_50.txt']);
d2 = readmatrix(['hw4data/jacobi_50_res.txt']);
d3 = readmatrix(['hw4data/gs_50_res.txt']);
d4 = readmatrix(['hw4data/sor_50_190_res.txt']);
%d = readmatrix(['hw4data/ss_poisson_g.txt']);
%d2 = readmatrix(['hw4data/jacobi_g_res.txt']);
%d3 = readmatrix(['hw4data/gs_g_res.txt']);
%d4 = readmatrix(['hw4data/sor_g_190_res.txt']);

x = d(:,3); % x cell center
y = d(:,4); % y cell center
u = d(:,5); % numeric solution
%u = zeros(size(x));

xv = linspace(min(x), max(x), 100);
yv = linspace(min(y), max(y), 100);
[X,Y] = meshgrid(xv, yv);
Z = griddata(x,y,u,X,Y);

if pblm == 2
	% all terms after 1 in analytical sln sum are insignificant
	% see test code below
	n = 1;
	f = sinh(n*pi*x).*cos(n*pi*y)./(n*n*pi*pi*sinh(2*n*pi));
	ua = 0.25*x - 4*f;
	Za = griddata(x,y,ua,X,Y);

	% calculate percent error
	err = abs((u-ua)./ua)*100;
	avgerr = mean(err)

	zmin = min([min(min(Z)) min(min(Za))]);
	zmax = max([max(max(Z)) max(max(Za))]);
	zlevels = linspace(zmin,zmax,16);

	colormap jet
	%contour(X,Y,Z,16,'ShowText','on','DisplayName','numeric');
	contour(X,Y,Z,zlevels,'--','ShowText','on','DisplayName','numeric');
	hold on;
	%contour(X,Y,Za,16,'--','ShowText','on','DisplayName','analytic');
	contour(X,Y,Za,zlevels,'-','ShowText','on','DisplayName','analytic');
	c = colorbar;
	c.Label.String = 'T(x,y)';
	legend('location','northwest');
	xlabel('x');
	ylabel('y');
	set(gca,'FontSize',16,'color',[0.5 0.5 0.5]);
	%set(gca,'FontSize',16,'color',[0.85 0.85 0.85]);
	%set(gca,'FontSize',16,'color','k');
	%set(gcf, 'Position',  [500, 500, 1000, 800])
	pbaspect([2 1 1])

	% plot convergence values
	figure;
	semilogy(d2(:,1),d2(:,2),'k','DisplayName','Jacobi');
	hold on; grid on;
	semilogy(d3(:,1),d3(:,2),'r','DisplayName','GS');
	semilogy(d4(:,1),d4(:,2),'b','DisplayName','SOR');
	xlabel('Num Iterations');
	ylabel('Residual (absolute)');
	set(gca,'FontSize',16);
	legend('location','northeast');

	%x = 1.9091
	%y = .9545 %x = .09
	%y = .05
	%f = @(x,y,n) sinh(n*pi*x)*cos(n*pi*y)/(n*n*pi*pi*sinh(2*n*pi))
	%fsum = 0;
	%for n=1:2:17
		%n
		%f(x,y,n)
		%fsum = fsum + f(x,y,n)
	%end
	%ua = 0.25*x - 4*fsum
	%ua = 0.25*x - 4*f(x,y,1)

elseif pblm == 3
	colormap jet
	%surf(X,Y,Z);
	contourf(X,Y,Z,16);
	xlabel('x');
	ylabel('y');
	c = colorbar;
	c.Label.String = '\phi(x,y)';
	set(gca,'FontSize',16,'color',[0.5 0.5 0.5]);
	set(gcf, 'Position',  [500, 500, 1000, 800])

	% plot convergence values
	figure;
	semilogy(d2(:,1),d2(:,2),'k','DisplayName','Jacobi');
	hold on; grid on;
	semilogy(d3(:,1),d3(:,2),'r','DisplayName','GS');
	semilogy(d4(:,1),d4(:,2),'b','DisplayName','SOR');
	xlabel('Num Iterations');
	ylabel('Residual (relative ratio)');
	set(gca,'FontSize',16);
	legend('location','northeast');

	% plot convergence values for SOR omega comparison
	figure;
	%d5 = readmatrix(['hw4data/sor_50_025_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 0.25');
	%hold on; grid on;
	%d5 = readmatrix(['hw4data/sor_50_050_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 0.5');
	%d5 = readmatrix(['hw4data/sor_50_075_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 0.75');
	d5 = readmatrix(['hw4data/sor_50_125_res.txt']);
	semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.25');
	d5 = readmatrix(['hw4data/sor_50_150_res.txt']);
	hold on; grid on;
	semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.5');
	d5 = readmatrix(['hw4data/sor_50_175_res.txt']);
	semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.75');
	d5 = readmatrix(['hw4data/sor_50_180_res.txt']);
	semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.8');
	d5 = readmatrix(['hw4data/sor_50_190_res.txt']);
	semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.9');
	%d5 = readmatrix(['hw4data/sor_50_200_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 2.0');
	xlabel('Num Iterations');
	ylabel('Residual (relative ratio)');
	set(gca,'FontSize',16);
	legend('location','northeast');

	%figure;
	%d5 = readmatrix(['hw4data/sor_g_025_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 0.25');
	%hold on; grid on;
	%d5 = readmatrix(['hw4data/sor_g_050_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 0.5');
	%d5 = readmatrix(['hw4data/sor_g_075_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 0.75');
	%d5 = readmatrix(['hw4data/sor_g_125_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.25');
	%d5 = readmatrix(['hw4data/sor_g_150_res.txt']);
	%hold on; grid on;
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.5');
	%d5 = readmatrix(['hw4data/sor_g_175_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.75');
	%d5 = readmatrix(['hw4data/sor_g_180_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.8');
	%d5 = readmatrix(['hw4data/sor_g_190_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 1.9');
	%d5 = readmatrix(['hw4data/sor_g_200_res.txt']);
	%semilogy(d5(:,1),d5(:,2),'DisplayName','\omega = 2.0');
	%xlabel('Num Iterations');
	%ylabel('Residual (relative ratio)');
	%set(gca,'FontSize',16);
	%legend('location','northeast');
end

