% time frequency analysis

% clear all vars and plots
close all; clear all; clc;

load('svddata_horn.mat');

sigx = amp_x(500,:);
t = t;

%dt = mean(diff(t));
%Fs = 1 / dt;
% logic pulled from polytec sample CalculateFFT.m
Fs = (usd_x.XCount - 1) / (usd_x.XMax - usd_x.XMin);

%figure
%subplot(3,1,1)
%plot(t*1e6,sigx*1e3)
%xlabel('time [\mus]')
%ylabel('amplitude (x velocity [mm/s])')
%title('signal x vel at pos 500')

%subplot(3,1,2)
	%pspectrum(sigx)
	%pspectrum(sigx,'FrequencyResolution',.05) 
	%pspectrum(amp_x(:,[23 47 500 1093]))
%pspectrum(sigx,Fs,'Leakage',1,'FrequencyLimits',[100e3, 600e3])
%subplot(3,1,3)
%pwelch(sigx,[],[],[],Fs)

% played with various wl vals (sample window width), still only getting one value
%figure
%env = envelope(sigx,80,'rms');
	%env = envelope(sigx,80,'peak');
	%env = envelope(sigx,80,'analytic');
	%plot(t,env);  % do this to see what the actual envelope looks like
%pulsewidth(env,Fs)

% locate frequency peaks by estimating mean frequency
%f = meanfreq(sigx,Fs,[100e3 3000e3]);
%round(f)

%pspectrum(sigx,Fs,'spectrogram','Leakage',1,'OverlapPercent',0,'MinThreshold',-200,...
%'FrequencyLimits',[100e3 3000e3],'TimeResolution',10e-6)

% cwt
figure;
cwt(sigx,Fs);  % call without return val to plot (todo: figure this out)
wt = cwt(sigx,Fs);

% https://www.mathworks.com/help/wavelet/ref/scal2frq.html
figure;
[cfs,f] = cwt(sigx,Fs);
contour(t,f,abs(cfs).^2); 
axis tight;
grid on;
xlabel('Time');
ylabel('Approximate Frequency (Hz)');
title('CWT with Time vs Frequency');

% load rectanble
%load('svddata_rect.mat');
%sigx = amp_x(637,:);
%figure;
%cwt(sigx,Fs);

