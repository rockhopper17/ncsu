% Andrew Navratil
% MAE 253 Spring 2018
% Lab 3 - Airfoil Lift
% Due 2018-04-09

% clear all vars and plots
close all; clear all; clc;

% constants / conversions / coefficients
psf_to_pa = 47.88;		% 47.88 pa / 1 psf
rhoAir = 1.18;			% density air (kg/m^3)
muAir = 1.846e-5;		% dynamic viscosity air (Pa s)
TF = 1.2512;			% wind tunnel turbulence factor
chord = 304.8;			% airfoil chord (mm)

% Import ALL data
% Column definitions in the alpha_*.dat files: Tap Number | Tap X-Coordinate (mm) | Tap Y-Coordinate (mm) | Dynamic Pressure (psf) | 10 Static Gauge Pressure Readings (psf)
for i = -6:24
	fname = sprintf('data/Lab3/re_5e5/alpha_%d.dat',i);
	data = load(fname);

	xc = data(:,2) ./ chord;
	pgauge = mean(data(:,5:end),2);		% pass dim value of 2 to mean for averaging columns
	qinf = data(:,4);					% dynamic pressure
	cp = pgauge ./ qinf;

	cpVxc(:,:,i+7) = [xc,cp];
end

% plot data for cp vs x/c
fig1 = figure(1);
hold on;
grid on;

[nrows,nccols,npages] = size(cpVxc);
for i = 1:npages
	plot(cpVxc(:,1,i), cpVxc(:,2,i),'b');
end

set(gca,'Ydir','reverse');
title('Pressure Coefficient vs Normalized x-coordinate');
xlabel('x/c');
ylabel('Cp');

