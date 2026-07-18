close all; clear all; clc;

if 1
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
if 0
% plot the k-field and head field to confirm values
% change v3_n1 to correct version and num procs
nprocs = 1
k=[],h=[]
for i = 0:nprocs-1
	d = readmatrix(['a5/slndata_',int2str(i),'_v3_n1.txt']);
	k = [k d(:,2)'];
	h = [h d(:,3)'];
end

x0=0,xL=10,dx=(xL-x0)/1000
x = [dx:dx:xL];

figure;
plot(x,k,'r-');
xlabel('x (m)');
ylabel('k (m/d)');
set(gca,'FontSize',16);

figure;
plot(x,h,'b-');
xlabel('x (m)');
ylabel('h (m)');
set(gca,'FontSize',16);

end
%==============================================================================
if 0
% calculate c0 and c1 coefficients for analytical solution
% h(0)=1, h(10)=0
% 4ac = 0.0056 > b^2 = 0.0049
a = 0.007, b = -0.07, c = 0.2

f = @(x) (2/sqrt(4*a*c - b*b)) * atan( (2*a*x + b) / (sqrt(4*a*c - b*b)) )

f(0)   % = -91.4243
f(10)  % = 91.4243

% plugging back into h = c0*f(x) + c1 we get
% c0 = -0.0055, c1 = 0.5

end
