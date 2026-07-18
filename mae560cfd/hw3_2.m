close all; clear all; clc;

%d = readmatrix(['hw3data/slndata_2_1.dat']); % sc 1 = RK4
d = readmatrix(['hw3data/slndata_2_2.dat']); % sc 2 = Crank-Nicolson

x = d(:,2);
u = d(:,3);

n = 100;
gridlen = 10.0;
dval = 0.1;
x0 = 5.0;

t = 2.0;
f1 = (1/sqrt(4*pi*dval*t))*exp((-(x-x0).^2)/(4*dval*t));
t = 4.0;
f2 = (1/sqrt(4*pi*dval*t))*exp((-(x-x0).^2)/(4*dval*t));

% plot
plot(x,f1,'k-.','DisplayName','exact t=2');
hold on;
plot(x,f2,'k--','DisplayName','exact t=4');
plot(x,u,'b-','DisplayName','numeric');

xlabel('x');
ylabel('f(x)');
set(gca,'FontSize',16);
legend('location','northeast');

