clear all;
clc;
close all;

BW=1588*10^-9                              % Bragg wavelength
pe=0.22                                    % photo-elastic constant

%file=dir('*.csv');                           % Find csv files in the folder list folder content
%filecount=length(file);                      % number of CSV files in the folder

% fnum=1:Remote, fnum=2:Direct
for fnum=1:2
%for fnum=2

if fnum==1
	fldr='20190619_Remote/'
	pos = 61;
else
	fldr='20190626_Direct/'
	pos = 12; 
end

%FBGcurve=file(1).name;                      % read FBG spectrum (its file name should be written such that MATLAB reads it first)
FBGcurve=strcat(fldr,'scope_0.csv');                      % read FBG spectrum (its file name should be written such that MATLAB reads it first)
FBGdata=csvread(FBGcurve,2,0);

%figure('units','normalized','outerposition',[0 0 1 1])      % create a window for plotting
%for i=2:filecount
filecount=15
freqvals=(300:50:1000);
npos = [30:78]; % direct
veldir = ['y'];

% loop all frequenices - each has a single csv file from FBG laser and svd/mat from LDV
for i=1:filecount
	%*************************************************************%
	% FBG %
	%*************************************************************%

	%s=file(i).name;                           
	s=strcat(fldr,'scope_',num2str(i),'.csv');                           
	
	% Read data from files and put in 'm' matrix (each cell contains p x q variables)
	m{i}=csvread(s,2,0);   
	
	% Extract actual data from 'm' matrix and put them in matrix.
	k=m{1,i};                               
	
	% Extract only voltage value (before excitation) and put in in 'average' matrix
	data(:,i)=k(1:1000,2:2);                
	time(:,:)=k(1:1000,1:1);

	meanvalue(:,i)=mean(mean(data(:,i),2),1);     
	centeredgraph(:,i)=(meanvalue(:,i)-data(:,i));

	[c index]= min(abs(FBGdata(1:250,2)-meanvalue(:,i) )); 
	%closest value to the mean value to find the edge slope location
	%V/s, Linear regression

	X = [ones(length(FBGdata(index-10:index+10,1:1)),1) FBGdata(index-10:index+10,1:1)];
	slope_VS=X\FBGdata(index-10:index+10,2:2);
	slope(i,1)=abs(slope_VS(2,1))*(188/10^-9);  %V/s * s/nm

	windowSize = 1;                             % filter filter (1 is no filtering?)
	b=(1/windowSize)*ones(1,windowSize) ;       % Define number of point that you want to use for rational transfer function
	a=1;                                        % Amplitude variable, usually 1
	FilteredGraph(:,i)=filtfilt(b,a,centeredgraph(:,i)/(slope(i,1)*BW*(1-pe)));      
	% Actual filtering function. Original values ('GraphMean' ) to filtered values ( 'FilteredGraph' )

	% save peak to peak value for fbg
	p2pfbg(fnum,i) = (max(FilteredGraph(:,i)) - min(FilteredGraph(:,i)))*1000000;

	%*************************************************************%
	% LDV %
	%*************************************************************%
	fnames = [string(sprintf('%04d',freqvals(i)))];
	matfile = strcat(fldr,fnames(1),'.mat');
	load(matfile);

	sig = amp_x(pos,:);

	% save peak to peak value for ldv
	p2pldv(fnum,i) = max(sig) - min(sig);

end % end freqvals file loop

end % end fnum (remote or direct)

plotvalsrem = p2pfbg(1,:) ./ p2pldv(1,:);
plotvalsdir = p2pfbg(2,:) ./ p2pldv(2,:);

plot(freqvals,plotvalsrem,'r.','MarkerSize',25,'DisplayName','Remote');
hold on;
grid on;
plot(freqvals,plotvalsdir,'b.','MarkerSize',25,'DisplayName','Direct');
%ylabel('peak to peak [\mu\epsilon]');
ylabel('peak to peak normalized by input signal');
xlabel('frequency [kHz]');
title('Calculated strain vs excitation frequency for direct and remote bonded fiber');
set(gca,'FontSize',18);
legend('show','Location','Northwest');
set(gca,'xdir','reverse');

