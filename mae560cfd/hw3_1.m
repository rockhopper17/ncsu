close all; clear all; clc;

% ic 1 = square wave
%d = readmatrix(['hw3data/slndata_1_1_1.dat']); % sc 1 = central diff
d = readmatrix(['hw3data/slndata_1_1_2.dat']); % sc 2 = upwind

% ic 2 = sine wave
%d = readmatrix(['hw3data/slndata_1_2_1.dat']); % sc 1 = central diff
%d = readmatrix(['hw3data/slndata_1_2_2.dat']); % sc 2 = upwind

% ic 3 = Gaussian
%d = readmatrix(['hw3data/slndata_1_3_1.dat']);
%d = readmatrix(['hw3data/slndata_1_3_2.dat']);

n = 100;
gridlen = 1.0;
k = 5.0;
%h = gridlen/n;
x = d(:,2);
u = d(:,3);

f = [zeros(1,25) ones(1,50) zeros(1,25)];  % ic 1
%f = sin(2*pi*k*x);  % ic 2
%f = exp(-50*(x--0.5).^2); % ic 3

% plot
plot(x,f,'k-.','DisplayName','exact');
hold on;
plot(x,u,'b-','DisplayName','numeric');

xlabel('x');
ylabel('f(x)');
set(gca,'FontSize',16);
legend('location','northeast');

