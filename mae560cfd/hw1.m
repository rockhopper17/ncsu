close all; clear all; clc;

% pblm 5 matrix eigenvalues
% doc spdiags
if 1
	for N = 5:5:50
		%N = 5;
		e = ones(N,1);

		% wave eqn
		%A = spdiags([-e 0*e e],-1:1,N,N); % creates sparse matrix, only stores diags
		%A(1,N) = -1; % set top right corner value
		%A(N,1) = 1; % set bottom left corner value
		
		% heat eqn
		A = spdiags([e -2*e e],-1:1,N,N); 
		A(1,N) = 1; 
		A(N,1) = 1; 
	
		%full(A) % prints the full matrix with 0's filled in
		eig(full(A))
	end

% pblms 1,2,3
elseif 0

	%t=[0:0.1:15]; % pblm 1 & 2
	%y=4*exp(-2*t); % pblm 1
	%y=4*exp(-2*t-0.0033*t.^3); % pblm 2

	t=[0:0.1:6]; % pblm 3
	%y=0.175*cos(4.04351*t); % pblm 3a
	y=exp(-2*t).*(0.0995943*sin(3.51426*t) + 0.175*cos(3.51426*t)); % pblm 3b

	plot(t,y,'-b','DisplayName','exact sln','LineWidth',3);
	hold on;

	n = 'iv';

	d = load(['hw1data/pblm3b' num2str(n) '-0.txt']);
	%plot(d(:,1),d(:,2),'.--k','MarkerSize',15,'DisplayName','\Deltat = 0.1');
	plot(d(:,1),d(:,2),'.-k','MarkerSize',15,'DisplayName','\Deltat = 0.15');
	d = load(['hw1data/pblm3b' num2str(n) '-1.txt']);
	plot(d(:,1),d(:,2),'*--k','MarkerSize',10,'DisplayName','\Deltat = 0.5');
	d = load(['hw1data/pblm3b' num2str(n) '-2.txt']);
	plot(d(:,1),d(:,2),'o:k','MarkerSize',10,'DisplayName','\Deltat = 1.0');

	ylabel('y(t)');
	xlabel('t');
	set(gca,'FontSize',18);
	axis([0 6 -.25 .25]);
	legend;

% pblm 4a,b
elseif 0
	%d = load(['hw1data/pblm4aiv-0.txt']); % t,x,y,z columns
	d = load(['hw1data/pblm4biv-0.txt']); % t,x,y,z columns

	t = d(:,1);
	x = d(:,2);
	y = d(:,3);
	z = d(:,4);

	subplot(2,2,1);
	plot(x,y,'k-');
	title('xy plane');
	ylabel('y');
	xlabel('x');
	set(gca,'FontSize',16);
	
	subplot(2,2,2);
	plot(x,z,'b-');
	title('xz plane');
	ylabel('z');
	xlabel('x');
	set(gca,'FontSize',16);

	subplot(2,2,3);
	plot(y,z,'r-');
	title('yz plane');
	ylabel('z');
	xlabel('y');
	set(gca,'FontSize',16);

	subplot(2,2,4);
	plot(t,x,'k-','DisplayName','x');
	hold on;
	plot(t,y,'b-','DisplayName','y');
	plot(t,z,'r-','DisplayName','z');
	title('xyz vs t');
	ylabel('x,y,z');
	xlabel('t');
	legend;
	set(gca,'FontSize',16);

% pblm 4
elseif 0
	d1 = load(['hw1data/pblm4c1iv-0.txt']);
	d2 = load(['hw1data/pblm4c2iv-0.txt']);

	t = d1(:,1);
	x = d1(:,2);
	y = d1(:,3);
	z = d1(:,4);
	x2 = d2(:,2);
	y2 = d2(:,3);
	z2 = d2(:,4);

	subplot(2,2,1);
	plot(x,y,'k-','DisplayName','y(0)=6');
	hold on;
	plot(x2,y2,'b:','DisplayName','y(0)=6.01');
	title('xy plane');
	ylabel('y');
	xlabel('x');
	set(gca,'FontSize',16);
	legend('location','northwest');
	
	subplot(2,2,2);
	plot(x,z,'k-','DisplayName','y(0)=6');
	hold on;
	plot(x2,z2,'b:','DisplayName','y(0)=6.01');
	title('xz plane');
	ylabel('z');
	xlabel('x');
	set(gca,'FontSize',16);
	legend('location','northwest');

	subplot(2,2,3);
	plot(y,z,'k-','DisplayName','y(0)=6');
	hold on;
	plot(y2,z2,'b:','DisplayName','y(0)=6.01');
	title('yz plane');
	ylabel('z');
	xlabel('y');
	set(gca,'FontSize',16);
	legend('location','northwest');

	figure;

	subplot(2,2,1);
	plot(t,x,'k-','DisplayName','y(0)=6');
	hold on;
	plot(t,x2,'b:','DisplayName','y(0)=6.01');
	title('x vs t');
	ylabel('x');
	xlabel('t');
	legend;
	set(gca,'FontSize',16);
	legend('location','northwest');

	subplot(2,2,2);
	plot(t,y,'k-','DisplayName','y(0)=6');
	hold on;
	plot(t,y2,'b:','DisplayName','y(0)=6.01');
	title('y vs t');
	ylabel('y');
	xlabel('t');
	legend;
	set(gca,'FontSize',16);
	legend('location','northwest');

	subplot(2,2,3);
	plot(t,z,'k-','DisplayName','y(0)=6');
	hold on;
	plot(t,z2,'b:','DisplayName','y(0)=6.01');
	title('z vs t');
	ylabel('z');
	xlabel('t');
	legend;
	set(gca,'FontSize',16);
	legend('location','northwest');

end
