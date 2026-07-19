% frequency analysis - learn FFT (reading Lyons book)

% clear all vars and plots
close all; clear all; clc;

%load('svddata_horn.mat');
load('svddata_4_y.mat');
npos = 349;
%npos = 437;

sigx = amp_x(npos,:)*1e3; % convert m/s to mm/s
%sigx = mean(amp_x(:,:))*1e3;

dt = mean(diff(t));
Fs = 1 / dt;
%Fs = (usd_x.XCount - 1) / (usd_x.XMax - usd_x.XMin); % logic from polytec CalculateFFT.m
T = 1/Fs;
%t2 = (0:N-1)*T;

% manually performing a DFT (discrete fourier transform)
% attempt to pull out 300kHz

% x(n) where n = time-domain index of input samples n = 0,1,2,...,N
% also X(m) where m = frequency-domain index for m = 0,1,2,...,N
N = length(sigx);
freqraw = zeros(N,1); % array of fourier transform values - will be complex number
freqmags = zeros(N,1); % array of frequency magnitudes - norm(freqraw)

fres = Fs/N; % frequency resolution - actual freq lines to calculate
maxf = Fs; % max frequency corresponds to sampling rate
freqrange = (0:fres:maxf-fres)'; % frequency buckets

% find m for 300kHz
m = (300000 * N / Fs) + 1; % +1 since we start at 1 not 0
m1 = floor(m);  % need m to be integer values, so get closest ones
m2 = ceil(m);

fourier = @(m,n) sigx(n) .* exp(-j*2*pi*(n-1)*(m-1)/N);
%f300m1 = sum(fourier(m1,[1:N]));
%f300m2 = sum(fourier(m2,[1:N]));

for m = 1:N
	freqraw(m) = sum(fourier(m,[1:N]));
end

%freqmags = norm(freqraw);
%freqmags = arrayfun(@(n) norm(freqraw(n,:)), 1:size(freqraw,1));
freqmags = abs(freqraw/N); % note: if value is complex, abs returns magnitude
%powmags = freqmags.^2;

subplot(3,1,1)
plot(t,sigx)
subplot(3,1,2)
plot(freqrange,freqmags)

% reduce to one-sided: see matlab doc for fft
freqmags = freqmags(1:N/2+1);
freqmags(2:end-1) = 2*freqmags(2:end-1);
freqrange = freqrange(1:N/2+1);

subplot(3,1,3)
plot(freqrange,freqmags)

% find first n peaks
%magpeaks = zeros(numpts,3);
magpeaks = zeros(1,3);
fmax = freqmags;
[mag,m] = max(fmax);
magpeaks(1,1) = freqrange(m);
fmax(m) = 0;
[mag,m] = max(fmax);
magpeaks(1,2) = freqrange(m);
fmax(m) = 0;
[mag,m] = max(fmax);
magpeaks(1,3) = freqrange(m);

%for pt = 1:1
	%for m = 1:numel(freqrange)
		%mag = freqmags(m) % get magnitude of freq m
		%f = freqrange(m) % get actual freq
		%if magpeaks(pt,1) < mag
			%magpeaks(pt,3) = magpeaks(pt,2);
			%magpeaks(pt,2) = magpeaks(pt,1);
			%magpeaks(pt,1) = f;
		%elseif magpeaks(pt,2) < mag
			%magpeaks(pt,3) = magpeaks(pt,2);
			%magpeaks(pt,2) = f;
		%elseif magpeaks(pt,3) < mag
			%magpeaks(pt,3) = f;
		%end
	%end
%end

disp('frequencies')
freqrange(m1-5:m1+5)
disp('freqmags')
freqmags(m1-5:m1+5)

%if false
%subplot(3,1,3)
%plot(freqrange,powmags)
%end

%*************************************
% using matlab functions
fftraw = fft(sigx);
fftmags = abs(fftraw)';
[pxx,f] = pwelch(sigx,[],[],[],Fs);

disp('fftmags')
fftmags(m1-5:m1+5)

%figure;
%plot(freqrange,fftmags)

% stft learn
figure;
[sp,fp,tp] = pspectrum(sigx,Fs,'spectrogram','FrequencyLimits',[200e3 500e3]);
%pspectrum(sigx,Fs,'spectrogram','FrequencyLimits',[200e3 500e3]);
pspectrum(sigx,Fs,'spectrogram');
idx300 = find(fp == 300e3);
figure;
plot(tp*1e6,sp(idx300,:));

%*************************************
% modified from CalculateFFT.m
	% calculate the FFT. we have to transpose the read in data because the
	% FFT is calculated column-wise whereas the data of the different
	% measurement points is stored in rows.
	%Y = fft(sigx')';
	% the number of FFT lines is half of the number of time samples
	%nLines = size(sigx,2) / 2;
	% we do not use the DC fft line
	%Y = Y(:,2:nLines+1);
	% normalize the FFT
	%Y = Y/nLines;
	% update the user signal description
	%samplefreq = (usd_x.XCount - 1) / (usd_x.XMax - usd_x.XMin);
	%resolution = 0.5*samplefreq/nLines;

% from polytech Theory Manual.pdf
% 2.1 harmonic vibrations sample breakdown
%A = 1; % amplitude
%f = 20/1000; % frequency [mHz (Hz in ms)]
%w = 2*pi*f; % angular frequency
%w0 = deg2rad(60); % zero phase angle [deg to rad]

%tt = [-50:0.001:100]; % time [ms]

%figure;
%plot(tt, A*cos(w*tt + w0),'k-','LineWidth',2);
%hold on; grid on;
%plot(tt, A*cos(w0)*cos(w*tt),'r--');
%plot(tt, -A*sin(w0)*sin(w*tt),'b--');
%plot(tt, A*cos(w0)*cos(w*tt)-A*sin(w0)*sin(w*tt),'y-');


