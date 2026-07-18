close all; clear all; clc;

%==============================================================================
% plot mflops, exec time
if 1
	% fgw bsub executed on henry2 
	% mflops, exec time, num procs printed to gw.out and compiled in gwout.txt
	% then manually entered in here for plotting
	procs = [1 2 4 8 16]
	mflops0010 = [6024 12913 26306 44328 68427]
	times0010 = [27.9877 13.0564 6.4093 3.8035 2.4639]
	mflops0100 = [6020 13264 29128 45476 76475]
	times0100 = [280.0738 127.1239 57.8888 37.0790 22.0489]
	mflops1000 = [6072 12646 28744 39367 55587]
	times1000 = [2776.5876 1333.3860 586.6255 428.3259 303.3453]

	semilogy(procs,times0010,'*--','MarkerSize',10,'DisplayName','t = 10d');
	hold on;
	semilogy(procs,times0100,'+--','MarkerSize',10,'DisplayName','t = 100d');
	semilogy(procs,times1000,'^--','MarkerSize',10,'DisplayName','t = 1000d');
	xlabel('Number of Processors');
	ylabel('Elapsed Time (s)');
	set(gca,'FontSize',16);
	legend('location','northeast');

	figure;
	plot(procs,mflops0010,'*--','MarkerSize',10,'DisplayName','t = 10d');
	hold on;
	plot(procs,mflops0100,'+--','MarkerSize',10,'DisplayName','t = 100d');
	plot(procs,mflops1000,'^--','MarkerSize',10,'DisplayName','t = 1000d');
	xlabel('Number of Processors');
	ylabel('Mflops');
	set(gca,'FontSize',16);
	legend('location','northwest');

end
%==============================================================================
% print solution
if 0
	nprocs = 16
	u = []
	for i = 0:nprocs-1
		istr = sprintf('%02d',i)
		%d = importdata(['minidata0010/slndata_',istr,'_0010.txt']);
		%d = importdata(['minidata0100/slndata_',istr,'_0100.txt']);
		d = importdata(['minidata1000/slndata_',istr,'_1000.txt']);
		u = [u;d];
	end

	x = linspace(0,1000,16*64+2)';
	y = linspace(0,500,499+2)';
	z = reshape(u,[499+2,16*64+2]);

	colormap jet
	contourf(x,y,z,16);
	xlabel('x');
	ylabel('y');
	c = colorbar;
	c.Label.String = 'h(x,y)';
	set(gca,'FontSize',16);
	set(gcf,'Position',[500, 500, 1000, 800]);
	pbaspect([2 1 1]);

end
%==============================================================================
% calculate K coefficients
if 0
	% get values from sol.a, sol.b, sol.c, sol.d
	syms a b c d x y k
	f = a*x + b*y + c*x*y + d - k
	eqn1 = subs(f,{x,y,k},{0,0,2});
	eqn2 = subs(f,{x,y,k},{1000,0,1});
	eqn3 = subs(f,{x,y,k},{0,500,1});
	eqn4 = subs(f,{x,y,k},{1000,500,2});
	sol = solve(eqn1,eqn2,eqn3,eqn4);

	% confirm with matrix solution Ax=b
	A = [0 0 0 1; 1000 0 0 1; 0 500 0 1; 1000 500 1000*500 1];
	b = [2;1;1;2];
	x = A\b
end
