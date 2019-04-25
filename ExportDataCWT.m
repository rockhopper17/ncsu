% process cwt for all points and save to mat file
% to be run after ExportData.m on an svd

% clear all vars and plots
close all; clear all; clc;

%load('svddata.mat'); % orig x_8cm test data
%load('svddata2.mat'); % orig x_8cm test data combined with scan plate

%load('svddata_horn.mat'); % test horn
%svdmatname = 'svddata_horn2.mat';

%load('svddata_rect.mat'); % test rectangle
%svdmatname = 'svddata_rect2.mat';

%load('svddata.mat');
%svdmatname = 'svddata_horn2.mat';

load('svddata_4_y.mat');
%svdmatname = 'svddata_4_y_CWT.mat';
svdmatname = 'svddata_4_y_ft.mat';

%load('svddata_2_x.mat');
%svdmatname = 'svddata_2_x_CWT.mat';

%load('svddata_exp4_y.mat');
%svdmatname = 'svddata_exp4_y_CWT.mat';

Fs = (usd_x.XCount - 1) / (usd_x.XMax - usd_x.XMin); % sample rate
numt = length(t); % num time data points
numpts = length(xyz); % num location points

% pull out positions and scale to mm
%x = xyz(:,1) * 1e3;
%x = abs(xyz(:,1)) * 1e3; % flip the _2_x
%y = xyz(:,2) * 1e3;
y = xyz(:,1) * 1e3; % swap for y oriented horns
x = xyz(:,2) * 1e3;
%xpts = unique(round(x)); % need to round _2_x since it's misaligned
%ypts = unique(round(y));
xpts = unique(x);
ypts = unique(y);

% trim the time range if desired
%tmin = 313;
%tmax = 800;
tmin = 1;
tmax = numel(t);

% get num cols
numcols = numel(xpts);

% preallocate array to hold time values for a single data point
sigx = zeros(1,numt);

% preallocate array to hold 300 kHz magnitude values for each pt/time
sigxt = zeros(numpts,numt);
sigxtcol = zeros(numcols,numt);
ptcols = zeros(numpts,1);  % col for each pt
%sigxtpks = zeros(numpts,numt);
%sigxtsum = zeros(1,numpts);

% fourier transform variables
fres = Fs/numt; % frequency resolution - actual freq lines to calculate
numfreqs = numt/2; % number of frequencies that can be measured
freqrange = [0:fres:fres*(numfreqs-1)]; % frequency buckets

ftform = zeros(numpts,numfreqs);
magpeaks = zeros(numpts,3);
ftformcol = zeros(numcols,numfreqs);
magpeakscol = zeros(numcols,3);

%*****************************************************************************
if false
% loop columns
for xidx = 1:numcols
	ptsidx = find(x == xpts(xidx)); % get all points in column

	sigx = mean(amp_x(ptsidx,:));
	sigxtcol(xidx,:) = sigx;
	ptcols(ptsidx) = xidx;

	%*****************************************
	% compute fourier transform	
	freqraw = zeros(numfreqs,1); % array of fourier transform values - will be complex number
	freqmags = zeros(numfreqs,1); % array of frequency magnitudes - norm(freqraw)

	for m = 0:numfreqs-1
		for n = 0:numt-1
			freqraw(m+1) = freqraw(m+1) + (sigx(n+1) * exp(-j*2*pi*n*m/numt) );
		end
	end

	% get magnitudes
	freqmags = abs(freqraw/numt); % note: if value is complex, abs returns magnitude
	%freqmags(2:end-1) = 2*freqmags(2:end-1);

	% store fourier transform magnitudes for this column
	ftformcol(xidx,:) = freqmags;

	% find first 3 peaks
	%fmax = freqmags;
	fmax = freqmags(2:end); % ignore DC term (0Hz term, the average of all samples)
	[mag,m] = max(fmax);
	magpeakscol(xidx,1) = freqrange(m);
	fmax(m) = 0;
	[mag,m] = max(fmax);
	magpeakscol(xidx,2) = freqrange(m);
	fmax(m) = 0;
	[mag,m] = max(fmax);
	magpeakscol(xidx,3) = freqrange(m);

	magpeaks(ptsidx,1) = magpeakscol(xidx,1);
	magpeaks(ptsidx,2) = magpeakscol(xidx,2);
	magpeaks(ptsidx,3) = magpeakscol(xidx,3);

	%plot(freqrange*1e-3,ftformcol(xidx,:)*1e3);
	xidx
	magpeakscol(xidx,1)
end

end

%*****************************************************************************
% loop points
for ptidx = 1:numpts
	% pull out data for the single data point
	sigx = amp_x(ptidx,:);

	%*****************************************
	% compute fourier transform	
	freqraw = zeros(numfreqs,1); % array of fourier transform values - will be complex number
	freqmags = zeros(numfreqs,1); % array of frequency magnitudes - norm(freqraw)

	for m = 0:numfreqs-1
		for n = 0:numt-1
			freqraw(m+1) = freqraw(m+1) + (sigx(n+1) * exp(-j*2*pi*n*m/numt) );
		end
	end

	% get magnitudes
	freqmags = abs(freqraw/numt); % note: if value is complex, abs returns magnitude
	%freqmags(2:end-1) = 2*freqmags(2:end-1);

	% store fourier transform magnitudes for this point
	ftform(ptidx,:) = freqmags;

	% find first 3 peaks
	%fmax = freqmags;
	fmax = freqmags(2:end); % ignore DC term (0Hz term, the average of all samples)
	[mag,m] = max(fmax);
	magpeaks(ptidx,1) = freqrange(m);
	fmax(m) = 0;
	[mag,m] = max(fmax);
	magpeaks(ptidx,2) = freqrange(m);
	fmax(m) = 0;
	[mag,m] = max(fmax);
	magpeaks(ptidx,3) = freqrange(m);

	%*****************************************
	% get the wavelet transform data
	[wt,f] = cwt(sigx,Fs);
	%[wt,f] = cwt(sigx,'bump',Fs);

	% pull out the index for freq closest to peak 1 freq
	%[~,idx300] = min(abs(f - 300e3)); 
	[~,pkidx] = min(abs(f - magpeaks(ptidx,1))); 

	% retrieve cwt calculated magnitude of 300 kHz signal at each time step
	% and load into new array
	sigxt(ptidx,tmin:tmax) = abs(wt(pkidx,tmin:tmax));

	% get peaks and save only peak magnitudes into sigxtpks
	%[pks,locs] = findpeaks(sigxt(ptidx,tmin:tmax));
	%sigxtpks(ptidx,locs) = sigxt(ptidx,locs);

	% get sum of magnitudes over full time range
	%sigxtsum(ptidx) = sum(abs(wt(idx300,tmin:tmax)));

	ptidx
	magpeaks(ptidx,1)
	pkidx
end


% save desired workspace variables
clear tmin tmax sigx ptidx idx300 pks locs m n mag freqraw freqmags fmax pkfreq
save(svdmatname);
