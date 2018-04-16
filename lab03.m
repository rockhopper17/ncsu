% Andrew Navratil
% MAE 253 Spring 2018
% Lab 3,4,5 - Airfoil Lift and Drag with Xfoil
% Due 2018-04-16

% clear all vars and plots
close all; clear all; clc;

% constants / conversions / coefficients
chord = 304.8;			% airfoil chord (mm)
ReNum = '7e5';			% Reynolds Number - change this to match folder name for 2-5e5, 5e5, 6e5, 7e5
						% this is utilized as folder name, titles in plots, and jpg file save names
AlphaLow = -6;			% iterator value for angles of attack - min
AlphaHigh = 22;			% iterator value for angles of attack - max

%===========================================================================
% LIFT
%===========================================================================

% init some collections
cpData = {};
clData = [];
idx = 1;

% Column definitions in the alpha_*.dat files: Tap Number | Tap X-Coordinate (mm) | Tap Y-Coordinate (mm) | Dynamic Pressure (psf) | 10 Static Gauge Pressure Readings (psf)
for i = AlphaLow:AlphaHigh
	fname = sprintf('data/Lab3/re_%s/alpha_%d.dat',ReNum,i);
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

%===========================================================================
% DRAG
%===========================================================================

% init some collections
pdefData = {};
cdData = [];
idx = 1;

% Column definitions in the alpha_*.dat files: Spanwise Tap Location (mm) | Dynamic Pressure (psf) | 10 Total Gauge Pressure Readings (psf)

for i = AlphaLow:3:AlphaHigh
	fname = sprintf('data/Lab5/re_%s/alpha_%d.dat',ReNum,i);
	data = load(fname);

	yc = data(:,1) ./ chord;
	pgauge = data(:,3:end);
	numReadings = size(pgauge,2);
	pgaugeAvg = mean(pgauge,2);
	qinf = data(:,2);
	pdef = (qinf - pgauge) ./ qinf;
	pdefAvg = mean(pdef,2);

	pdefData{idx} = sortrows([yc pdefAvg]);
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

%===========================================================================
% XFOIL
%===========================================================================
fname = sprintf('data/Lab4/red_%s.pol',ReNum);
fid = fopen(fname);

for i = 1:12
	fgetl(fid);
end

pol = fscanf(fid,'%g %g %g %g %g %g %g',[9 inf]);
pol = pol';
pol = sortrows(pol);  % do this so we don't get a line connecting end point to middle

fclose(fid);

alphaXfoil = pol(:,1);
clXfoil = pol(:,2);
cdXfoil = pol(:,3);

%===========================================================================
% PLOTS
%===========================================================================

% plot data for cp vs x/c
fig1 = figure(1);
hold on;
grid on;

for i = 1:numel(cpData)
	plot(cpData{i}(:,1), cpData{i}(:,2),'b');
end

set(gca,'Ydir','reverse');
title(sprintf('Pressure Coefficient vs Normalized x-coordinate (Re %s)',ReNum));
xlabel('x/c');
ylabel('Cp');


% plot data for cl vs alpha
fig2 = figure(2);
hold on;
grid on;

% first plot the avg cl data as a line
leg2(1) = plot(clData(:,1),clData(:,2),'.k-');

% plot xfoil
leg2(2) = plot(alphaXfoil,clXfoil,'k--');

% then plot each individual cl for each gauge to act as error bar
for i = 1:numReadings
	plot(clData(:,1),clData(:,2+i),'*b');
end

title(sprintf('Lift Coefficient vs Angle of Attack (Re %s)',ReNum));
xlabel('\alpha');
ylabel('C_{l}');
legend([leg2(1) leg2(2)],{'Experiment','Xfoil'},'Location','Southeast');

% plot data for pdef vs y/c
fig3 = figure(3);
hold on;
grid on;

for i = 1:numel(pdefData)
	plot(pdefData{i}(:,2), pdefData{i}(:,1));
end

title(sprintf('Pressure Defecit vs Normalized y-coordinate (Re %s)',ReNum));
ylabel('y/c');
xlabel('(p_{\infty} - p_{wake})/q_{\infty}');

% plot data for cd vs alpha
fig4 = figure(4);
hold on;
grid on;

% first plot the avg cd data as a line
leg4(1) = plot(cdData(:,1),cdData(:,2),'r--');

% plot xfoil
leg4(2) = plot(alphaXfoil,cdXfoil,'k-');

% then plot each individual cd for each gauge to act as error bar
for i = 1:numReadings
	plot(cdData(:,1),cdData(:,2+i),'*b');
end

title(sprintf('Drag Coefficient vs Angle of Attack (Re %s)',ReNum));
xlabel('\alpha');
ylabel('C_{d}');
legend([leg4(1) leg4(2)],{'Experiment','Xfoil'},'Location','Northwest');

% plot drag polar - cd vs cl
fig5 = figure(5);
hold on;
grid on;

% plot experiment data
% plot only every third cl data to match the alphas we have cd data for
leg5(1) = plot(clData(1:3:end,2),cdData(:,2),'r--');

% plot xfoil
leg5(2) = plot(clXfoil,cdXfoil,'k-');

title(sprintf('Drag Polar (Re %s)',ReNum));
xlabel('C_{l}');
ylabel('C_{d}');
legend([leg5(1) leg5(2)],{'Experiment','Xfoil'},'Location','Northwest');

% save plots to jpg
saveas(fig1,sprintf('lab03_cp_vs_xc_Re_%s.jpg',ReNum));
saveas(fig2,sprintf('lab03_cl_vs_alpha_Re_%s.jpg',ReNum));
saveas(fig3,sprintf('lab03_pdef_vs_yc_Re_%s.jpg',ReNum));
saveas(fig4,sprintf('lab03_cd_vs_alpha_Re_%s.jpg',ReNum));
saveas(fig5,sprintf('lab03_drag_polar_Re_%s.jpg',ReNum));

