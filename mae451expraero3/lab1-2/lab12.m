% Andrew Navratil
% MAE 451 Expr Aero 3 Fall 2019
% Lab 1-2 Vortex Shedding and Turbulence Analysis
%         using Constant Temperature Anemometry
% Due 2019-09-30

% clear all vars and plots
close all; clear all; clc;

% constants
rho = 1.14; % air density [kg/m^3]
mu = 1.962e-5; % dynamic viscosity (mu) [kg/ms]
diam = 0.1016; % cylinder diameter [m]

psf_to_pa = 47.88; % conversion for psf to Pascal [Pa/psf]

% locals
eud = []; % struct to hold POS* (or NEG*), ECorrected(1x3), velocity(1x3), Tacq(1x3)
turb = []; % struct to hold position, velocity, % turbulence
vor = []; % struct to hold lam/turb, Strouhal num, Reynolds num

% load data from lab 1 part 1
files = dir('lab1data/instrumentation_data_Q_*');

for idx = 1:numel(files)
	fname = files(idx).name;
	data = load(fullfile(files(idx).folder, fname));

	qpit = data(:,3); 
	tacq = data(:,4);
	twire = data(:,5);
	tref = data(:,6);
	eacq = data(:,7);

	uinf = sqrt(2*qpit/rho);
	ecorr = sqrt((twire-tref)/(twire-tacq))*eacq;

	posf = extractBetween(fname,'_Q_','.dat'); % POS* or NEG*

	eud = [eud struct('posf',posf,'ecorr',ecorr,'uinf',uinf,'tacq',tacq)];
end

% sort for correct curve plotting
uinf = [eud.uinf]';
ecorr = [eud.ecorr]';
[uinf,ii] = sort(uinf);
ecorr = ecorr(ii);

% calculate calibration curve for each postion
for idx=1:3
	puinf(idx,:) = polyfit(ecorr(:,idx),uinf(:,idx),2);
end

% load data from lab 1 part 2
files = dir('lab1data/voltage_time_history_Q_*');

for idx = 1:numel(files)
	fname = files(idx).name;
	data = load(fullfile(files(idx).folder, fname));

	t = data(:,1); 
	eacq = data(:,2);

	% pull out eud record to get tacq,uinf for this run & position from part 1 data
	posf = extractBetween(fname,'_Q_','_'); % POS*
	posn = str2double(extractBetween(fname,'_position_','.dat')); % position num
	eudp = eud(strcmp({eud.posf},posf));

	% use latest twire,tref since they are constant for all runs
	% use eacq from part 2 and tacq from corresponding POS* from part 1
	tcorr = sqrt((twire(1)-tref(1))/(twire(1)-eudp.tacq(posn)));
	ecorrt = tcorr*eacq;

	% use polynomial fit to calculate velocities
	uinft = polyval(puinf(posn,:),ecorrt);

	% calculate percent turbulence
	uinfmean = mean(uinft);
	uinfstd = std(uinft);
	turbt = uinfstd*100/uinfmean;
	turb = [turb struct('posn',posn,'uinft',eudp.uinf(posn),'turbt',turbt)];
end

% load data from lab 2
files = dir('lab2data/voltage_time_history_Q_*');

for idx = 1:numel(files)
	fname = files(idx).name;
	data = load(fullfile(files(idx).folder, fname));

	qpsf = extractBetween(fname,'_Q_','_'); % dynamic pressure reading
	flowtype = extractBetween(fname,[char(qpsf) '_'],'_position'); % lam/turb
	
	t = data(:,1); 
	eacq = data(:,2);

	% fourier transform, get peak frequency
	dt = t(2) - t(1);
	Fs = 1 / dt;
	T = 1 / Fs;
	L = length(t);
	fres = Fs/L;

	ftform = fft(eacq); % call matlab fft func
	ftform = abs(ftform(1:L/2+1)/L); % get single-sided spectrum
	% ignore 0Hz DC term, only look 3Hz - 500Hz
	[mag,fidx] = max(ftform(ceil(3/fres):ceil(500/fres))); 
	f = fidx*fres-fres; % index * frequency resolution gives peak frequency

	% calculate Strouhal and Reynolds numbers
	uinft = sqrt(2*str2double(qpsf)*psf_to_pa/rho);
	S = f*diam/uinft;
	Re = rho*uinft*diam/mu;
	vor = [vor struct('flowtype',flowtype,'S',S,'Re',Re)];
end

% plots for part 1 calibration curves
for idx=1:3
	uinft = polyval(puinf(idx,:),ecorr(:,idx));

	figure;
	plot(uinf(:,idx),ecorr(:,idx),'o',...
		'DisplayName','Data Acquired','MarkerSize',10);
	hold on; grid on;
	plot(uinft,ecorr(:,idx),'-', ...
		'DisplayName','Best polynomial fit','LineWidth',2);
	title(['Position ' num2str(idx)]);
	ylabel('E_{corrected} (V DC)');
	ylim([2 3]);
	xlabel('V_{inf} (m/s)');
	xlim([0 35]);
	legend('location','northwest');
	set(gca,'FontSize',14);
end

% plot % turbulence
figure;
for idx=1:3
	uinftt(:,idx) = [turb([turb.posn] == idx).uinft];
	turbtt(:,idx) = [turb([turb.posn] == idx).turbt];

	plot(uinftt(:,idx),turbtt(:,idx),'*',...
		'DisplayName',['Position ' num2str(idx)],'LineWidth',2);
	hold on; grid on;
end

uinftavg = mean(uinftt,2);
turbtavg = mean(turbtt,2);

plot(uinftavg,turbtavg,'x',...
	'DisplayName','Avg Turb vs Avg Vel','LineWidth',2);

ylabel('% Turbulence');
xlabel('V_{inf} (m/s)');
xlim([0 35]);
legend('location','northeast');
set(gca,'FontSize',14);

% pull in data from web digitized Bearman plot
refdata = csvread('BearmanPlotData.csv');

figure;
plot(refdata(:,1),refdata(:,2),'o-','DisplayName','Bearman Data','LineWidth',2);
hold on; grid on;
vorp = vor(strcmp({vor.flowtype},'lam'));
plot([vorp.Re],[vorp.S],'x','DisplayName','Laminar','LineWidth',2);
vorp = vor(strcmp({vor.flowtype},'turb'));
plot([vorp.Re],[vorp.S],'*','DisplayName','Turbulent','LineWidth',2);
ylabel('Strouhal Number');
xlabel('Reynolds Number');
set(gca,'FontSize',14);
legend('location','northwest');

