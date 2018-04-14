% Andrew Navratil
% MAE 253 Spring 2018
% Lab 3 - Airfoil Lift
% Due 2018-04-16

% clear all vars and plots
close all; clear all; clc;

% constants / conversions / coefficients
psf_to_pa = 47.88;		% 47.88 pa / 1 psf
rhoAir = 1.18;			% density air (kg/m^3)
muAir = 1.846e-5;		% dynamic viscosity air (Pa s)
TF = 1.2512;			% wind tunnel turbulence factor
chord = 304.8;			% airfoil chord (mm)

% init some collections
cpData = {};
clData = [];
pdefData = {};
cdData = [];
idx = 1;

% LIFT
% Import data for our lab: re_5e5
% Column definitions in the alpha_*.dat files: Tap Number | Tap X-Coordinate (mm) | Tap Y-Coordinate (mm) | Dynamic Pressure (psf) | 10 Static Gauge Pressure Readings (psf)
for i = -6:24
	fname = sprintf('data/Lab3/re_5e5/alpha_%d.dat',i);
	data = load(fname);

	xc = data(:,2) ./ chord;			% x/c value
	pgauge = data(:,5:end);
	numReadings = size(pgauge,2);
	pgaugeAvg = mean(pgauge,2);		% pass dim value of 2 to mean for averaging columns
	qinf = data(:,4);					% dynamic pressure
	cp = pgauge ./ qinf;				% pressure coefficient
	cpAvg = mean(cp,2);			% pass dim value of 2 for averaging columns in each row

	cpData{idx} = [xc cpAvg];
	idx = idx + 1;

	cl = [i trapz(xc,cpAvg)];

	% now loop each individual cp value to get cl for each gauge reading
	for j = 1:numReadings
		cl = [cl trapz(xc,cp(:,j))];
	end
	clData = [clData; cl];
end

% plot data for cp vs x/c
fig1 = figure(1);
hold on;
grid on;

for i = 1:numel(cpData)
	plot(cpData{i}(:,1), cpData{i}(:,2),'b');
end

set(gca,'Ydir','reverse');
title('Pressure Coefficient vs Normalized x-coordinate');
xlabel('x/c');
ylabel('Cp');

% plot data for cl vs alpha
fig2 = figure(2);
hold on;
grid on;

% first plot the avg cl data as a line
plot(clData(:,1),clData(:,2),'.k-');

% then plot each individual cl for each gauge to act as error bar
for i = 1:numReadings
	plot(clData(:,1),clData(:,2+i),'*b');
end

title('Lift Coefficient vs alpha');
xlabel('\alpha');
ylabel('C_{l}');

%============================================================================
% DRAG
% Import data for our lab: re_5e5
% Column definitions in the alpha_*.dat files: Spanwise Tap Location (mm) | Dynamic Pressure (psf) | 10 Total Gauge Pressure Readings (psf)

% reset idx
idx = 1;

for i = -6:3:24
	fname = sprintf('data/Lab5/re_5e5/alpha_%d.dat',i);
	data = load(fname);

	yc = data(:,1) ./ chord;
	pgauge = data(:,3:end);
	numReadings = size(pgauge,2);
	pgaugeAvg = mean(pgauge,2);
	qinf = data(:,2);
	pdef = qinf - pgauge;
	pdefAvg = mean(pdef,2);

	pdefData{idx} = [yc pdefAvg];
	idx = idx + 1;

	% zero out all negative pdef values as the interim correction
	pdef(pdef < 0) = 0;
	pdefAvg(pdefAvg < 0) = 0;
	
	cd = [i trapz(yc,pdefAvg)];

	% now loop each individual pdef value to get cd for each gauge reading
	for j = 1:numReadings
		cd = [cd trapz(yc,pdef(:,j))];
	end
	cdData = [cdData; cd];
end

% plot data for pdef vs y/c
fig3 = figure(3);
hold on;
grid on;

for i = 1:numel(pdefData)
	plot(pdefData{i}(:,2), pdefData{i}(:,1));
end

title('Pressure Defecit vs Normalized y-coordinate');
ylabel('y/c');
xlabel('(p_{\infty} - p_{wake})/q_{\infty}');

% plot data for cd vs alpha
fig4 = figure(4);
hold on;
grid on;

% first plot the avg cd data as a line
plot(cdData(:,1),cdData(:,2),'r--');

% then plot each individual cd for each gauge to act as error bar
for i = 1:numReadings
	plot(cdData(:,1),cdData(:,2+i),'*b');
end

title('Drag Coefficient vs alpha');
xlabel('\alpha');
ylabel('C_{d}');

