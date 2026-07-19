%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process SVD File: Global Variables / Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear all vars and plots to start
close all; clear all; clc;

% looks for .svd (or .txt) and .mat files with filename entered in fnames
%fnames = ["fibertest"];
%fnames = ["alum_thick_ab4"];
%fnames = ["fibertest2"];
%fnames = ["fibertest2_625"];
fnames = ["0450"];

% example of proessing multiple files together
% assumes time synced, will append all data points together
%fnames = ["Scan_time","Scan_time_extended fiber"]; % ex of multipile files

% index number of point(s) to analyze: see map for values
%npos = [20];
npos = [5,20,35];
%npos = [1:41];
%npos = [1,5,10,15,20,25,30,35,41];
%npos = [1:400];
%npos = [17,450,324];

% velocity direction(s) to plot
veldir = ['y'];
%veldir = ['y','z'];
%veldir = ['x','y','z'];

% time range to limit (index value, not actual time value)
tmin = 1;
tmax = 1500;
%tmin = 1;
%tmax = size(t,1);

% flags for plots to display
showmap = true; % display map of scan points w position numbers
showtime = true; % display time-domain plot
showfreq = true; % display frequency-domain plot
% frequency-domain type
% 1 = manual CalcFourierTransform with 3 peaks labaled
% 2 = pwelch
freqtype = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get/Export SVD Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% export data from svd using PolyTec functions
% will create a mat file based on the first file name
% if the mat file already exists, it will load data from there

% use name of first file as mat file name, title on plots, etc
svdtitle = fnames(1);
numf = numel(fnames);

% load data from mat file if it exists, otherwise export data from svd
matfile = strcat(fnames(1),'.mat');
if isfile(matfile)
	disp('mat file found, loading data');
	load(matfile);
else
	% init data structures to hold position and velocity values
	xyz = double.empty(0);
	amp_x = double.empty(0);
	amp_y = double.empty(0);
	amp_z = double.empty(0);

	% loop files and process
	for fidx = 1:numf
		svdfile = strcat(fnames(fidx),'.svd');
		txtfile = strcat(fnames(fidx),'.txt');

		% svd file
		if isfile(svdfile)
			disp('svd file found, processing PolyTec data');

			xyz_t = GetXYZCoordinates(svdfile,0);

			[t, amp_x_t, usd_x] = GetPointData(svdfile, 'Time', 'Vib X', 'Velocity', 'Samples', 0, 0);
			[t, amp_y_t, usd_y] = GetPointData(svdfile, 'Time', 'Vib Y', 'Velocity', 'Samples', 0, 0);
			[t, amp_z_t, usd_z] = GetPointData(svdfile, 'Time', 'Vib Z', 'Velocity', 'Samples', 0, 0);
			
			%if fidx == 1	
				%imageData = GetVideoImage(filetoproc);
			%end

		% txt file (single point)
		elseif isfile(txtfile)
			disp('txt file found, processing single point PolyTec data');

			d = importdata(txtfile,'\t',5); % load data, skip first 5 lines

			xyz_t = [0,0,0]; % default position value

			t = d.data(:,1)'; % time values
			amp_x_t = d.data(:,2)'; % x vel
			amp_y_t = d.data(:,3)'; % y vel
			amp_z_t = d.data(:,4)'; % z vel
		else
			disp('no svd, txt, or mat file found');
			return;
		end

		% add current file data to total
		xyz = [xyz; xyz_t];
		amp_x = [amp_x; amp_x_t];
		amp_y = [amp_y; amp_y_t];
		amp_z = [amp_z; amp_z_t];
	end

	% save desired workspace variables
	%clear xyz_t amp_x_t amp_y_t amp_z_t fidx filetoproc d
	disp('saving mat file with PolyTec data in Matlab data structures');
	save(matfile,'t','xyz','amp_x','amp_y','amp_z');
end

numt = size(t,2); % num time data points (number of columns)
nump = size(xyz,1); % num location points (number of rows)
numdir = numel(veldir); % num directions to analyze (1 or 2 or 3)
numpts = numel(npos); % num points to analyze

if tmax > numt
	tmax = numt;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Show Map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if showmap == true

% get x,y coordinates converted to mm
x = xyz(:,1) * 1e3; 
y = xyz(:,2) * 1e3;

% get video image data for plotting as background
%xImg = linspace(min(x), max(x), size(imageData, 2));
%yImg = linspace(min(y), max(y), size(imageData, 1));

% create map with index number on each point
scatter(x, y, [], 'w');
hold on; grid on;
%image(xImg, yImg, imageData, 'CDataMapping', 'scaled');

for ptidx = 1:nump
	%xidx = find(xpts == x(ptidx)); % column number
	%yidx = find(ypts == y(ptidx)); % row number

	text(x(ptidx),y(ptidx),sprintf('%d',ptidx));
end

end % end showmap

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate Movie
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Time Domain (raw signal data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if showtime == true

for idxpt = 1:numpts
	figure;
	pos = npos(idxpt);

	for idxdir = 1:numdir
		dir = veldir(idxdir);
		
		if strcmp(dir,'x')
			sig = amp_x(pos,tmin:tmax);
		elseif strcmp(dir,'y')
			sig = amp_y(pos,tmin:tmax);
		elseif strcmp(dir,'z')
			sig = amp_z(pos,tmin:tmax);
		end
		
		% plot: convert time to microseconds and velocity to mm/s
		plot(t(tmin:tmax)*1e6, sig*1e3,'DisplayName',strcat(dir,' vel'));
		hold on; grid on;
	end

	title(sprintf('%s time-domain at point %d',replace(svdtitle,"_","\_"),pos));
	ylabel('velocity [mm/s]','FontSize',18);
	xlabel('time [\mus]','FontSize',18);
	set(gca,'FontSize',18);
	legend show;
end

end % end showtime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Discrete Fourier Transform: Plot Frequency Domain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if showfreq == true

%***********************************************%
% CalcFourierTransorm %
%***********************************************%
if freqtype == 1

% load data from ft mat file if it exists
matfile = strcat(fnames(1),'_ft.mat');
if isfile(matfile)
	disp('ft mat file found, loading data');
	load(matfile);

	numptsinmat = numel(ftformx);
	nposdiff = setdiff(npos,[ftformx.ptidx]);
else
	numptsinmat = 0;
	nposdiff = npos;
end

% check to see if new points are being analyzed and need dft calculated
if ~isempty(nposdiff) 
	for nptidx = 1:numel(nposdiff)
		ptidx = nposdiff(nptidx);
		disp(sprintf('processing dft for point %d',ptidx));
		
		% call manual function to calculate fourier transform
		[ftformx_t, fpeaksx_t] = CalcFourierTransform(t,amp_x(ptidx,:));
		[ftformy_t, fpeaksy_t] = CalcFourierTransform(t,amp_y(ptidx,:));
		[ftformz_t, fpeaksz_t] = CalcFourierTransform(t,amp_z(ptidx,:));

		ftformx(nptidx+numptsinmat) = struct('ptidx',ptidx,'freq',ftformx_t(:,1),'mag',ftformx_t(:,2),...
			'peakfreq',fpeaksx_t(:,1),'peakmag',fpeaksx_t(:,2));
		ftformy(nptidx+numptsinmat) = struct('ptidx',ptidx,'freq',ftformy_t(:,1),'mag',ftformy_t(:,2),...
			'peakfreq',fpeaksy_t(:,1),'peakmag',fpeaksy_t(:,2));
		ftformz(nptidx+numptsinmat) = struct('ptidx',ptidx,'freq',ftformz_t(:,1),'mag',ftformz_t(:,2),...
			'peakfreq',fpeaksz_t(:,1),'peakmag',fpeaksz_t(:,2));
	end

	% save desired workspace variables
	save(matfile,'ftformx','ftformy','ftformz');
end

for idxpt = 1:numpts
	figure;
	pos = npos(idxpt);

	for idxdir = 1:numdir
		dir = veldir(idxdir);
		
		if strcmp(dir,'x')
			ftform = ftformx([ftformx.ptidx] == pos);
		elseif strcmp(dir,'y')
			ftform = ftformy([ftformy.ptidx] == pos);
		elseif strcmp(dir,'z')
			ftform = ftformz([ftformz.ptidx] == pos);
		end
		
		freq = [ftform.freq]*1e-3; % Hz to kHz
		mag = [ftform.mag]*1e3; % m/s to mm/s
		peakfreq = [ftform.peakfreq]*1e-3;
		peakmag = [ftform.peakmag]*1e3;
		fres = freq(3) - freq(2);

		% plot magnitude vs frequency with top peaks
		plot(freq,mag,'DisplayName',strcat(dir,' dir'));
		hold on; grid on;
		text(peakfreq(1),peakmag(1),num2str(peakfreq(1)),'FontSize',18);
		text(peakfreq(2),peakmag(2),num2str(peakfreq(2)),'FontSize',18);
		text(peakfreq(3),peakmag(3),num2str(peakfreq(3)),'FontSize',18);
	end

	title(sprintf('%s frequency-domain at point %d',replace(svdtitle,"_","\_"),pos));
	ylabel('magnitude [mm/s]');
	xlabel('frequency [kHz]');
	set(gca,'FontSize',18);
	legend show;
end

%***********************************************%
% pwelch %
%***********************************************%
elseif freqtype == 2

% sampling frequency
dt = mean(diff(t));
Fs = 1 / dt;

for idxpt = 1:numpts
	%figure;
	pos = npos(idxpt);

	for idxdir = 1:numdir
		dir = veldir(idxdir);
		
		if strcmp(dir,'x')
			sig = amp_x(pos,tmin:tmax);
		elseif strcmp(dir,'y')
			sig = amp_y(pos,tmin:tmax);
		elseif strcmp(dir,'z')
			sig = amp_z(pos,tmin:tmax);
		end

		%if idxdir > 1
			figure;
		%end
		pwelch(sig,[],[],[],Fs);
		title(sprintf('%s: Welch Power Spectral Density Estimate at Point %d',replace(svdtitle,"_","\_"),pos));
	end
end
		
end % end freqtype

end % end showfreq
