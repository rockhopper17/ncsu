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

%load('svddata_4_y.mat');
%svdmatname = 'svddata_4_y_CWT.mat';

%load('svddata_2_x.mat');
%svdmatname = 'svddata_2_x_CWT.mat';

load('svddata_exp4_y.mat');
svdmatname = 'svddata_exp4_y_CWT.mat';

Fs = (usd_x.XCount - 1) / (usd_x.XMax - usd_x.XMin); % sample rate
numt = length(t); % num time data points
numpts = length(xyz); % num location points

% trim the time range
%tmin = 201;
%tmax = 800;
tmin = 1;
tmax = numel(t);

% preallocate array to hold time values for a single data point
sigx = zeros(1,numt);

% preallocate array to hold 300 kHz magnitude values for each pt/time
sigxt = zeros(numpts,numt);
sigxtpks = zeros(numpts,numt);
%sigxtsum = zeros(1,numpts);

for ptidx = 1:numpts
	% pull out data for the single data point
	sigx = amp_x(ptidx,:);

	% get the wavelet transform data
	%[wt,f] = cwt(sigx,Fs);
	[wt,f] = cwt(sigx,'bump',Fs);

	% pull out the index for our 300 kHz signal
	[~,idx300] = min(abs(f - 300e3)); 

	% retrieve cwt calculated magnitude of 300 kHz signal at each time step
	% and load into new array
	sigxt(ptidx,tmin:tmax) = abs(wt(idx300,tmin:tmax));

	% get peaks and save only peak magnitudes into sigxtpks
	[pks,locs] = findpeaks(sigxt(ptidx,tmin:tmax));
	sigxtpks(ptidx,locs) = sigxt(ptidx,locs);

	% get sum of magnitudes over full time range
	%sigxtsum(ptidx) = sum(abs(wt(idx300,tmin:tmax)));

	ptidx
end

% save desired workspace variables
clear Fs numt numpts tmin tmax sigx ptidx idx300 pks locs
save(svdmatname);
