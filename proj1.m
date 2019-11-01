close all; clear all; clc;

% test case: 1=sin, 2=runge
tc=2;

if tc==1
	% test cubic spline in general
	% see matlab doc for interp1 function
	% https://www.mathworks.com/help/matlab/ref/interp1.html#btwp6lt-1-xq
	x = 0:pi/4:2*pi; 
	v = sin(x);
	xq = 0:pi/16:2*pi;

	figure;
	vq2 = interp1(x,v,xq,'spline');
	plot(x,v,'o',xq,vq2,':.');
	xlim([0 2*pi]);
	title('Spline Interpolation');
	grid on;

	% now plot from c code output
	d=load('spline8.txt');
	figure;
	plot(x,v,'o',d(:,1),d(:,2),':.');
	grid on;
	xlim([0 2*pi]);

elseif tc==2
	% test trimatvec for A*p and final Ax=b sln for solcg
	%a=[3 0 0;.5 2 .5;0 0 3];
	%b=[7.885941644562334;13.655172413793103;7.885941644562334];
	%a*b % this is what A*p result from trimatvec should show
	%a\b % this is what Ax=b result from solcg for ctmp should show

	% build coeff vectors
	%a = [0.038461538461538464, 0.13793103448275862, 1,0.13793103448275862];
	%b = [-0.15819678897280715, -0.070836073644406916,  -3.998391343601253,-1.0353541809455684];

if false
	n = 8;

	x = -1:2/n:1;
	v = 1./(1+25*x.^2);
	xq = -1:2/(n*7):1;

	% run spline with matlab
	figure;
	vq2 = interp1(x,v,xq,'spline');
	plot(x,v,'o',xq,vq2,':.');
	title('Spline Interpolation');
	grid on;

	% now plot from c code output
	C = {'r','g','c','b'};
	nvals = [4 8 16 32];

	figure(2);
	x = -1:0.01:1;
	fr = 1./(1+25*x.^2);
	ph(5) = plot(x,fr,'k-','DisplayName','Runge');
	hold on;

	derr = load('err.txt');

	for idx=1:4
		n = nvals(idx);

		d=load(['spline' num2str(n) '.txt']);

		for i=1:n
			x = d(i,1):0.01:d(i+1,1);
			p = d(i,3:6); % coeffs d,c,b,a
			f = polyval(p,x);
			figure(2);
			plot(d(i,1),d(i,2),'o',x,f,'-','color',C{idx});
			hold on;
		end
		ph(idx) = plot(d(n+1,1),d(n+1,2),'o',...
			'color',C{idx},'DisplayName',['n=' num2str(n)]);
		hold on;
		
		%h = d(2,1) - d(1,1); % equal spacing for runge
		figure(3);
		plot(derr(idx,2),derr(idx,1),'o',...
			'color',C{idx},'LineWidth',2,'DisplayName',['n=' num2str(n)]);
		hold on;
	end

	figure(2);
	legend(ph,'location','northwest');

	figure(3);
	x = -1.5:0.01:0;
	p = derr(5,1:2); % coeffs b,a
	f = polyval(p,x);
	plot(x,f,'k-','DisplayName','least sq');
	grid on;
	legend('location','northwest');
end
	% unit circle
	n = 5;
	d=load(['spline' num2str(n) '.txt']);
	figure(4);
	for i=1:n
		x = d(i,1):-0.01:d(i+1,1);
		p = d(i,3:6); % coeffs d,c,b,a
		f = polyval(p,x);
		plot(d(i,1),d(i,2),'ob',x,f,'-b');
		hold on;
	end
	%plot(d(n+1,1),d(n+1,2),'ob');
	hold on;
	
end

