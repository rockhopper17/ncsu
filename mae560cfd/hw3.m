close all; clear all; clc;

% pblm 1
%d = readmatrix(['hw3data/slndata_1_1_1.dat']); % square wave, central diff
%d = readmatrix(['hw3data/slndata_1_1_2.dat']); % square wave, upwind
%d = readmatrix(['hw3data/slndata_1_2_1.dat']); % sine wave, central diff
%d = readmatrix(['hw3data/slndata_1_2_2.dat']); % sine wave, upwind
%d = readmatrix(['hw3data/slndata_1_3_1.dat']); % Gaussian, central diff
%d = readmatrix(['hw3data/slndata_1_3_2.dat']); % Gaussian, upwind

% pblm 2
d = readmatrix(['hw3data/slndata_2_1_1.dat']); % RK4, 100 cells
%d = readmatrix(['hw3data/slndata_2_2_1.dat']); % RK4, 200 cells
%d = readmatrix(['hw3data/slndata_2_1_2.dat']); % Crank-Nicolson, 100 cells
%d = readmatrix(['hw3data/slndata_2_2_2.dat']); % Crank-Nicolson, 200 cells

x = d(:,2); % grid (1D = x values)
u = d(:,3); % numeric solution

k = 1.0;
%k = 5.0;
%k = 10.0;
dval = 0.1;
x0 = 5.0;

% set exact function
%f = [zeros(1,25) ones(1,50) zeros(1,26)]; % square wave
%f = sin(2*pi*k*x); % sine wave
%f = exp(-50*(x-0.5).^2); % Gaussian

% diffusion (pblm 2)
t = 2.0;
f1 = (1/sqrt(4*pi*dval*t))*exp((-(x-x0).^2)/(4*dval*t));
t = 4.0;
f2 = (1/sqrt(4*pi*dval*t))*exp((-(x-x0).^2)/(4*dval*t));

% plot
%plot(x,f,'k-.','DisplayName','exact');
plot(x,f1,'k-.','DisplayName','exact t=2');
hold on;
grid on;
plot(x,f2,'k-.','DisplayName','exact t=4');
plot(x,u,'b--','DisplayName','numeric');

xlabel('x');
%ylabel('f(x)'); % pblm 1
ylabel('C(x)'); % pblm 2
set(gca,'FontSize',16);
legend('location','northeast');

