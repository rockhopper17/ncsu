% Andrew Navratil
% MAE 361 Fall 2018
% HW1 & HW2 & HW3
% Due 2018 09-10 & 09-17 & 09-24

% clear all vars and plots
close all; clear all; clc;

H = 4;			% in
R = 3;			% in
m = 15 / 32.2;	% lb s^2 / ft = slug
k = 15;			% lb / in
%c = 0.01;		% lb s / in
c = 0.5;		% lb s / in

syms theta;

dA1 = @(theta) R^2 * (1+cos(theta)).^2 + (H - R.*sin(theta)).^2;

f = @(theta) ((2*k) / (m*R)) * (1 - H / sqrt(R^2 * (1+cos(theta)).^2 + (H - R.*sin(theta)).^2)) * (H.*cos(theta) + R.*sin(theta));

df = @(theta) (-2*k*H/m) * dA1(theta).^(-3/2) .* (R*sin(theta) + H*cos(theta)).^2 + ...
		(2*k/(m*R)) * (1 - H*dA1(theta).^(-1/2)) .* (R*cos(theta) - H*sin(theta));

% using matlab diff to confirm manual derivative calc
df2 = matlabFunction( diff(f(theta)) );

%{
% HW1 plot
fig = figure(1);
colormap(jet);
fplot(f);
xlim([0 4*pi]);
set(gca,'XTick',0:pi/2:4*pi);
set(gca,'XTickLabel',{'0','pi/2','pi','3pi/2','2pi','5pi/2','3pi','7pi/2','4pi'});
line(xlim,[0 0]);
xlabel('theta(rad)');
ylabel('f(theta)');
%}

%***** HW 2 *****%

% converted to degrees
f0 = @(t) ( exp(-0.1193.*t) .* (0.1745 * cos(8.02.*t) + 0.0026 * sin(8.02.*t)) + pi) * 180 / pi;

% HW2 plot
fig = figure(1);
colormap(jet);
fplot(f0);
xlim([0 6.0]);
%ylim([-pi pi]);
%line(xlim,[0 0]);
ylim([160 200]);
grid on;
xlabel('time (s)');
ylabel('theta (deg)');

