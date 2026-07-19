% Andrew Navratil
% MAE 352 Expr Aero 2 Spring 2019
% Lab 4/5 Converging and Converging-Diverging Nozzle Analysis
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

DataFolderName = 'data/'; % data folder name, will have subfolders with data files
DataFileExtensions = '*.txt'; % data file extensions, txt here (could be dat, etc)

% isentropic relation for direct evaluation
f_isen = @(p1,p01) sqrt( ( (p01./p1).^((gamma-1)/gamma) - 1 ) .* (2/(gamma-1))  );

% array of structs to hold data for each run
pd4 = []; pd5 = [];

% *************************************************************************** %
% iterate all files with specified extension(s) in all subfolders and process data
% *************************************************************************** %

% get list of subfolders (exclude . and ..)
dataFolder = dir(DataFolderName);
subFolders = dataFolder([dataFolder.isdir]);
subFolders(ismember( {subFolders.name},{'.','..'})) = [];

%Column definitions in the provided data files:
%Tap Number | Tap Axial Positon (inches) | Nozzle Area Ratio (A/Ai) | P_static (psi) | P_O (psi) | Mass Flow Rate (slugs/second) | P_atm (psi) 
for idxi = 1:numel(subFolders)
	pd = [];
	files = dir(fullfile( subFolders(idxi).folder, subFolders(idxi).name, DataFileExtensions));
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

	if (strcmp(subFolders(idxi).name,'Tuesday_Session_20190305'))
		pd4 = pd;
	elseif (strcmp(subFolders(idxi).name,'Tuesday-Session_20190319'))
		pd5 = pd;
	end 
end

% *************************************************************************** %
% plots
% *************************************************************************** %
for labn = 4:5
	% set data for lab 4 or 5
	if labn == 4
		pd = pd4;
	else
		pd = pd5;
	end

	% ************************************ %
	% p/p0 vs tap dist
	% ************************************ %
	figure;
	for idxi = 1:numel(pd)
		plot(pd(idxi).tapndist, pd(idxi).ps ./ pd(idxi).p0);
		hold on; grid on;
	end

	% plot dashed line for choked cond at p/p0 = 0.5283
	ph(1) = yline(0.5283,'--k','DisplayName','Choked Condition (p/p0 = 0.5283)');

	if labn == 5
		ph(2) = xline(pd(1).tapndist(4),'--b','DisplayName','throat');
	end

	% configure plot
	set(gca,'FontSize',14);
	ylabel('p/p0');
	xlabel('Norm. Nozzle Dist.');
	title(['Lab ' num2str(labn) ': P/P0 vs Normalized Nozzle Distance']);
	legend(ph,'location','southwest');

	% ************************************ %
	% M vs tap dist
	% ************************************ %
	figure;
	for idxi = 1:numel(pd)
		plot(pd(idxi).tapndist, pd(idxi).M);
		hold on; grid on;
	end

	% plot dashed line for choked cond at M = 1
	ph(1) = yline(1.0,'--k','DisplayName','Choked Condition (M = 1)');

	if labn == 5
		ph(2) = xline(pd(1).tapndist(4),'--b','DisplayName','throat');
	end

	% configure plot
	set(gca,'FontSize',14);
	ylabel('M');
	xlabel('Norm. Nozzle Dist.');
	title(['Lab ' num2str(labn) ': Mach Number vs Normalized Nozzle Distance']);
	legend(ph,'location','northwest');

	% ************************************ %
	% MFP vs pb/p0
	% ************************************ %
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
	title(['Lab ' num2str(labn) ': Mass Flow Parameter vs Back Pressure Ratio']);

	% ************************************ %
	% exit M vs pb/p0
	% ************************************ %
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
	title(['Lab ' num2str(labn) ': Exit Mach Number vs Back Pressure Ratio']);

	% ************************************ %
	% lab 5 specific plots
	% ************************************ %
	if labn == 5
		% ************************************ %
		% pe/p0 vs pb/p0
		% ************************************ %
		figure;
		for idxi = 1:numel(pd)
			plot(pd(idxi).pb / pd(idxi).p0, pd(idxi).ps(9) / pd(idxi).p0,'b.','MarkerSize',10);
			hold on; grid on;
		end

		% plot dashed line for slope 1
		line('LineStyle','--');

		% configure plot
		set(gca,'FontSize',14);
		ylabel('pe/p0');
		xlabel('pb/p0');
		title(['Lab ' num2str(labn) ': Exit Pressure Ratio vs Back Pressure Ratio']);

		% ************************************ %
		% pt/p0 vs pb/p0
		% ************************************ %
		figure;
		for idxi = 1:numel(pd)
			plot(pd(idxi).pb / pd(idxi).p0, pd(idxi).ps(4) / pd(idxi).p0,'b.','MarkerSize',10);
			hold on; grid on;
		end

		% plot dashed line for choked cond at pb/p0 = 0.5283
		yline(0.5283,'--k');
		xline(0.5283,'--k');

		% configure plot
		set(gca,'FontSize',14);
		ylim([0 1.1]);
		ylabel('pt/p0');
		xlabel('pb/p0');
		title(['Lab ' num2str(labn) ': Throat Pressure Ratio vs Back Pressure Ratio']);
	end
end

