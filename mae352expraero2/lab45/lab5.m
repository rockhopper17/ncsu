% Andrew Navratil
% MAE 352 Expr Aero 2 Spring 2019
% Lab 5 Converging-Diverging Nozzle Analysis
% Due 2019-04-01

% clear all vars and plots
close all; clear all; clc;

% *************************************************************************** %
% constants, lookup data, and data structures %
% *************************************************************************** %
gamma = 1.4;  % ratio spec heats for air @stp
T0 = 22 + 273; % stagnation temp in kelvin
Ai = 3.17e-5; % inlet area in m^2
slugps_to_kgps = 14.5939; % slugs/s to kg/s

DataFolderName = 'DataLab5/Tuesday_Session_2019039/'; % data folder name
DataFileExtensions = '*.txt'; % data file extensions, txt here (could be dat, etc)

% isentropic relation for direct evaluation
f_isen = @(p1,p01) sqrt( ( (p01./p1).^((gamma-1)/gamma) - 1 ) .* (2/(gamma-1))  );

% array of structs to hold data for each run
pd = [];

% *************************************************************************** %
% iterate all files with specified extension(s) in all subfolders and process data
% *************************************************************************** %

%Column definitions in the provided data files:
%Tap Number | Tap Axial Positon (inches) | Nozzle Area Ratio (A/Ai) | P_static (psi) | P_O (psi) | Mass Flow Rate (slugs/second) | P_atm (psi) 
files = dir(fullfile(DataFolderName, '*.txt'));
files(ismember({files.name},{'README.txt'})) = []; % remove readme txt file

for idxj = 1:numel(files)
	data = load(fullfile(files(idxj).folder, files(idxj).name));

	ps = data(:,4) + data(1,7); % p_static - diff for each tap
	p0 = data(1,5) + data(1,7); % p0 - same for entire run
	pb = data(data(:,1) == 10, 4) + data(1,7); % back pressure at tap 10

	tapndist = data(:,2) ./ data(data(:,1) == 10, 2); % normalized dist by tap 10

	mdot = data(1,6) * slugps_to_kgps; % same mdot for entire run, just pull from first row
	Ae = data(data(:,1) == 9, 3) * Ai; % exit area at tap 9
	mfp = (mdot .* sqrt(T0)) / (Ae * p0); % mass flow parameter

	ps(ps > p0) = p0; % set all static pressures greater than stagnation to stagnation
	M = f_isen(ps,p0); % calculate mach number at each tap

	% add data to struct array
	pd = [pd struct('ps',ps,'p0',p0,'pb',pb,'tapndist',tapndist,'mfp',mfp,'M',M)];
end

% *************************************************************************** %
% plot p/p0 by normalized nozzle dist
% *************************************************************************** %
figure;
for idxi = 1:numel(pd)
	plot(pd(idxi).tapndist, pd(idxi).ps ./ pd(idxi).p0);
	hold on; grid on;
end

% plot dashed line for choked cond at p/p0 = 0.5283
ph(1) = yline(0.5283,'--k','DisplayName','Choked Condition (p/p0 = 0.5283)');

% configure plot
set(gca,'FontSize',14);
ylabel('p/p0');
xlabel('Norm. Nozzle Dist.');
title('P/P0 vs Normalized Nozzle Distance');
legend(ph,'location','southwest');

% *************************************************************************** %
% plot M by normalized nozzle dist
% *************************************************************************** %
figure;
for idxi = 1:numel(pd)
	plot(pd(idxi).tapndist, pd(idxi).M);
	hold on; grid on;
end

% plot dashed line for choked cond at M = 1
ph(1) = yline(1.0,'--k','DisplayName','Choked Condition (M = 1)');

% configure plot
set(gca,'FontSize',14);
ylabel('M');
xlabel('Norm. Nozzle Dist.');
title('Mach Number vs Normalized Nozzle Distance');
legend(ph,'location','northwest');

% *************************************************************************** %
% plot MFP by back pressure ratio
% *************************************************************************** %
figure;
for idxi = 1:numel(pd)
	plot(pd(idxi).pb / pd(idxi).p0, pd(idxi).mfp,'b.','MarkerSize',10);
	hold on; grid on;
end

% plot dashed line for choked cond at pb/p0 = 0.5283
xline(0.5283,'--k');

% configure plot
set(gca,'FontSize',14);
ylabel('MFP');
xlabel('pb/p0');
title('Mass Flow Parameter vs Back Pressure Ratio');

% *************************************************************************** %
% plot Exit Mach Number by back pressure ratio
% *************************************************************************** %
figure;
for idxi = 1:numel(pd)
	plot(pd(idxi).pb / pd(idxi).p0, pd(idxi).M(9),'r.','MarkerSize',10);
	hold on; grid on;
end

% plot dashed line for choked cond at pb/p0 = 0.5283
yline(1.0,'--k');
xline(0.5283,'--k');

% configure plot
set(gca,'FontSize',14);
ylabel('M');
xlabel('pb/p0');
title('Exit Mach Number vs Back Pressure Ratio');

