% process data saved in an ascii txt file, created by right-clicking on the analyze window
% after a single point scan run and copy pasting to notepad
% 5 header lines:
%Source File Name:	Scan
%Signal:	Time - Vib 3D Velocity - Samples

%Time	Time Signal X	Time Signal Y	Time Signal Z
%[ s ]	[ m/s ]	[ m/s ]	[ m/s ]

% clear all vars and plots
close all; clear all; clc;

% files with ascii exported data from polytec
% drew 1
%fnames{1} = '190411 bare surface.txt';
%fnames{2} = '190411 one sweep 1.txt';
%fnames{3} = '190411 five sec 1.txt';
%fnames{4} = '190411 thirty sec 1.txt';

% drew 2
%fnames{1} = '190411 bare surface.txt';
%fnames{2} = '190411 one sweep 2.txt';
%fnames{3} = '190411 five sec 2.txt';
%fnames{4} = '190411 thirty sec 2.txt';

% kevin
fnames{1} = 'no_spray.txt';
fnames{2} = 'low_spray.txt';
fnames{3} = 'medium_spray.txt';
fnames{4} = 'high_spray.txt';

set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
colormap('jet');

for idx = 1:4
	d = importdata(['coatingthickness/' fnames{idx}],'\t',5); % load data

	t = d.data(:,1); % time values
	amp_x = d.data(:,2); % x vel
	amp_y = d.data(:,3); % y vel
	amp_z = d.data(:,4); % z vel

	% call function to calculate fourier transform
	[ftform, fpeaks] = CalcFourierTransform(t,amp_x);

	% convert frequencies to kHz and magnitues to mm/s
	ftform(:,1) = ftform(:,1) * 1e-3; % Hz to kHz
	ftform(:,2) = ftform(:,2) * 1e3; % m/s to mm/s
	fpeaks(:,1) = fpeaks(:,1) * 1e-3; % Hz to kHz
	fpeaks(:,2) = fpeaks(:,2) * 1e3; % m/s to mm/s

	% plot
	subplot(4,1,idx);
	plot(ftform(:,1),ftform(:,2));
	hold on; grid on;
	text(fpeaks(:,1),fpeaks(:,2), num2str(fpeaks(:,1)));
	title(fnames{idx});
	ylabel('magnitude [mm/s]');
	xlabel('frequency [kHz]');
	set(gca,'FontSize',14);
end
