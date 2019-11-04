close all; clear all; clc;

% runge function
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
	
	figure(3);
	plot(derr(idx,2),derr(idx,1),'o',...
		'color',C{idx},'LineWidth',2,'DisplayName',['n=' num2str(n)]);
	hold on;
end

figure(2);
ylabel('f(x)');
xlabel('x');
legend(ph,'location','northwest');
set(gca,'FontSize',14);

figure(3);
x = -1.5:0.01:0;
p = derr(5,1:2); % coeffs b,a
f = polyval(p,x);
plot(x,f,'k-','DisplayName','least sq');
grid on;
legend('location','northwest');
ylabel('log(||e||_{2})');
xlabel('log(h_{n})');
set(gca,'FontSize',14);

% unit circle
n = 8;
dxc = load(['spline' num2str(n) 'ucx.txt']);
dyc = load(['spline' num2str(n) 'ucy.txt']);
figure(4);
for i=1:n
	p = dxc(i,3:6); % coeffs d,c,b,a for x
	x = polyval(p,[i-1:.01:i]);

	p = dyc(i,3:6); % coeffs d,c,b,a for y
	y = polyval(p,[i-1:.01:i]);

	plot(dxc(i,2),dyc(i,2),'ob',x,y,'-b');
	hold on;
end
ph2(1) = plot(dxc(n+1,2),dyc(n+1,2),'ob','DisplayName','Numerical cubic spline circle');

% plot true circle
t = linspace(0,2*pi,100);
x = cos(t);
y = sin(t);
ph2(2) = plot(x,y,'-k','DisplayName','True circle using cos and sin');
ylabel('f(x)');
xlabel('x');
set(gca,'FontSize',14);
legend(ph2,'location','northwest');

