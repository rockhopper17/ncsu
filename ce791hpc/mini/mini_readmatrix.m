close all; clear all; clc;

if 0
% fjacobi bsub executed on henry2 where mflops printed to fjacobi.out and copied here
%    run separately for each num procs (same .out file is used)
procs = [1 2 4 8]
mflops0 = [2229 715 945 757]  % version 0
mflops1a= [2637 2820 4063 4674]  % version 1 unsafe
mflops1b = [2404 2559 2586 2979]  % version 1 safe
mflops2 = [2266 2460 3035 3653]  % version 2
mflops3 = [2414 2605 3610 4416]  % version 3
mflops4 = [2324 2487 3175 3780]  % version 4
mflops5 = [2195 2816 3461 4153]  % version 5

figure;
plot(procs,mflops0,'*-','DisplayName','version 0');
hold on;
plot(procs,mflops1a,'+-.','DisplayName','version 1 (unsafe)');
plot(procs,mflops1b,'+-','DisplayName','version 1 (safe)');
plot(procs,mflops2,'.-','DisplayName','version 2');
plot(procs,mflops3,'^-','DisplayName','version 3');
plot(procs,mflops4,'s-','DisplayName','version 4');
plot(procs,mflops5,'d-','DisplayName','version 5');
xlabel('Number of Processors');
ylabel('Mflops');
set(gca,'FontSize',16);
legend('location','northwest');

end
%==============================================================================
% print solution
if 1
	%d = readmatrix(['minidata/slndata_010.txt']);
	%d = readmatrix(['minidata/slndata_050.txt']);
	%d = readmatrix(['minidata/slndata_100.txt']);
	%x = d(:,3);
	%y = d(:,4); 
	%u = d(:,5);
	
	nprocs = 16
	%x = [], y = [], u = []
	u = []
	for i = 0:nprocs-1
		istr = sprintf('%02d',i)
		d = importdata(['minidata0010/slndata_',istr,'_0010.txt']);
		%d = readmatrix(['minidata/slndata_',istr,'_0100.txt']);
		%d = readmatrix(['minidata/slndata_',istr,'_1000.txt']);
		%x = [x d(:,3)'];
		%y = [y d(:,4)'];
		%u = [u d(:,5)'];
		u = [u;d];
	end

	x = linspace(0,1000,16*64+2)';
	y = linspace(0,500,499+2)';
	z = reshape(u,[499+2,16*64+2]);
	%xv = linspace(min(x), max(x), 1000);
	%yv = linspace(min(y), max(y), 1000);
	%[X,Y] = meshgrid(xv, yv);
	%Z = griddata(x,y,u,X,Y,'linear');

	colormap jet
	%contourf(X,Y,Z,16);
	contourf(x,y,z,16);
	xlabel('x');
	ylabel('y');
	c = colorbar;
	c.Label.String = 'h(x,y)';
	t = get(c,'Limits');
	set(c,'Ticks',linspace(t(1),t(2),5))
	set(gca,'FontSize',16);
	set(gcf,'Position',[500, 500, 1000, 800])

end
%==============================================================================
% calculate K coefficients
if 0
	syms a b c d x y k
	f = a*x + b*y + c*x*y + d - k
	eqn1 = subs(f,{x,y,k},{0,0,2});
	eqn2 = subs(f,{x,y,k},{1000,0,1});
	eqn3 = subs(f,{x,y,k},{0,500,1});
	eqn4 = subs(f,{x,y,k},{1000,500,2});
	sol = solve(eqn1,eqn2,eqn3,eqn4);
	% get values from sol.a, sol.b, sol.c, sol.d

	% confirm with matrix solution Ax=b
	A = [0 0 0 1; 1000 0 0 1; 0 500 0 1; 1000 500 1000*500 1];
	b = [2;1;1;2];
	x = A\b

	%a = 0.007, b = -0.07, c = 0.2
	%f = @(x) (2/sqrt(4*a*c - b*b)) * atan( (2*a*x + b) / (sqrt(4*a*c - b*b)) )
	%f(0)   % = -91.4243
	%f(10)  % = 91.4243
	% plugging back into h = c0*f(x) + c1 we get
	% c0 = -0.0055, c1 = 0.5
end
