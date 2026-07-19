close all; clear all; clc;

% pblm 1c
if 0
	kh = linspace(0,pi);
	kshexact = kh.^2;
	ksh1 = (1 - cos(2*kh))/2;
	ksh2 = 2*(1 - cos(kh));

	plot(kh,kshexact,'r-','DisplayName','exact');
	hold on;
	plot(kh,ksh1,'k-','DisplayName','form 1');
	plot(kh,ksh2,'k--','DisplayName','form 2');

	xlabel('kh');
	ylabel('(k^*h)^2');
	set(gca,'FontSize',18);
	legend('location','northwest');

% pblm 2a
elseif 0
	A = [-1 1 2;1/2 1/2 2;-1/6 1/6 4/3];
	b = [-1;0;0];
	x = A\b

	kh = linspace(0,pi);
	kshexact = kh;
	kshre = (8*sin(kh) + sin(2*kh))/6;
	kshim = (3 - 4*cos(kh) - cos(2*kh))/6;

	plot(kh,kshexact,'r-','DisplayName','exact');
	hold on;
	plot(kh,kshre,'k-','DisplayName','Re');
	plot(kh,kshim,'k--','DisplayName','Im');

	xlabel('kh');
	ylabel('k^*h');
	set(gca,'FontSize',18);
	legend('location','northwest');

% pblm 2b
elseif 1
	format rat % this will give fraction answers

	A = [1 1 1 1;-1/2 -3/2 1/2 3/2;1/8 9/8 1/8 9/8;-1/48 -27/48 1/48 27/48];
	b = [-1;0;0;0];
	x = A\b

	kh = linspace(0,pi);
	kshexact = ones(size(kh)); % we are only looking at amplitude differences
	ksh = (9/8)*cos(kh/2) - (1/8)*cos(3*kh/2);

	plot(kh,kshexact,'r-','DisplayName','exact');
	hold on;
	plot(kh,ksh,'k-','DisplayName','modified');

	xlabel('kh');
	ylabel('k^*h');
	ylim([0 1.2]);
	set(gca,'FontSize',18);
	legend('location','southwest');

% pblm 3
elseif 0
	format rat

	syms h fi fiminus fiplus
	A = [h^2/12 0 1;13*h^2/12 -h 1; 13*h^2/12 h 1];
	B = [fi;fiminus;fiplus];
	x = A\B


end
