% Andrew Navratil
% MAE 451 Expr Aero 3 Fall 2019
% Lab 4 Engine Performance Analysis
% Due 2019-10-29

% clear all vars and plots
close all; clear all; clc;

% constants
rho = 862.75; % fuel density [kg/m^3]
r = 0.4445; % length of lever [m]
Qhv = 11.3e6; % fuel heating value [J/kg]
etaC = 0.99; % combustion efficiency

gms_to_N = 9.807e-3; % conversion g to N [N/g]
cm3_to_m3 = 1e-6; % conversion cubic centimeter to m^3 [m^3/cc^3]

% load data
data = load('data/Lab-4_Thursday-Session-Data_20191017.dat');

rpm = [data(:,1) data(:,2) data(:,3) data(:,4) data(:,5)];
force = [data(:,6) data(:,7) data(:,8) data(:,9) data(:,10)];
forcecorr = data(:,11);
fueltime = data(:,12);

% calculations
rpmavg = mean(rpm,2)/2; % divide in half for two blades
forceavg = mean(force - forcecorr,2) * gms_to_N;
torque = forceavg * r;
power = 2*pi * (rpmavg/60) .* torque;
fuelmdot = rho * 10 * cm3_to_m3 ./ fueltime;
etaTh = power ./ (fuelmdot * Qhv * etaC);

[rpmavg, sortidx] = sort(rpmavg);
torque = torque(sortidx,:);
power = power(sortidx,:);
etaTh = etaTh(sortidx,:);

% perform some analysis on polynomial degree fits
% loop degrees, calc R-squared value, but also look at plot
% do this for all 3: torque, power, efficiency
%testdata = torque;
%testdata = power;
%testdata = etaTh;
%plot(rpmavg*1e-3,testdata,'b*');
%hold on;
%for i = 2:length(rpmavg)-1
%for i = 5
	%[coeff, ~, mu] = polyfit(rpmavg,testdata,i);
	%f = polyval(coeff,rpmavg,[],mu);
	%yresid = testdata - f;
	%SSresid = sum(yresid.^2);
	%SStotal = (length(testdata)-1) * var(testdata);
	%rsq = 1 - SSresid/SStotal;

	%plot(rpmavg*1e-3,f); % plot so we can view to find smoothest curve

	%% display the degree and rsq value to output window
	%i
	%rsq	
%end

% torque
% 16 gives best rsq (0.9970) without error, but plot is not smooth
% 3 shows the smoothest plot with rsq 0.9336
degbest = 3;
[coeff, ~, mu] = polyfit(rpmavg,torque,degbest);
f = polyval(coeff,rpmavg,[],mu);

figure;
plot(rpmavg*1e-3,torque,'b*');
hold on; grid on;
plot(rpmavg*1e-3,f,'k');
ylabel('Engine Torque (N-m)');
xlabel('RPM x 1,000');
set(gca,'FontSize',14);

% power
% 17 gives best rsq (0.9986) without error, but plot is not smooth
% 5 shows the smoothest plot with rsq 0.9775 (no inflection points)
degbest = 5;
[coeff, ~, mu] = polyfit(rpmavg,power,degbest);
f = polyval(coeff,rpmavg,[],mu);

figure;
plot(rpmavg*1e-3,power,'b*');
hold on; grid on;
plot(rpmavg*1e-3,f,'k');
ylabel('Engine Power (W)');
xlabel('RPM x 1,000');
set(gca,'FontSize',14);

% thermal efficiency
% 17 gives best rsq (0.6631) without error, but plot is not smooth
% 5 shows the smoothest plot with rsq 0.3469 (least inflection points)
degbest = 5;
[coeff, ~, mu] = polyfit(rpmavg,etaTh,degbest);
f = polyval(coeff,rpmavg,[],mu);

figure;
plot(rpmavg*1e-3,etaTh*100,'b*');
hold on; grid on;
plot(rpmavg*1e-3,f*100,'k');
ylabel('Thermal Efficiency (%)');
xlabel('RPM x 1,000');
set(gca,'FontSize',14);
