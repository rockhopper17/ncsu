clear all; clc; close all;

%*************************************************************%
% LDV - Remote - Single Point Scan TXT Files %
%*************************************************************%
%fldr = '20190719_RemoteSinglePoint2/'
%fldr = '20190801_RemoteSinglePoint4/'
%fldr = '20190801_RemoteSinglePoint3/'
fldr = '20190808_LDVOnlyRemote/' % best data for paper
freqvals = (300:50:1000);
filecount=15
fnum = 1;

for i=1:filecount
	fname = string(sprintf('%04d',freqvals(i)));
	%txtfile = strcat(fldr,fname,'_BeforeBond.txt');
	%txtfile = strcat(fldr,fname,'_AfterBond.txt');
	txtfile = strcat(fldr,fname,'.txt');
	d = importdata(txtfile);
	t = d.data(:,1); % time
	sig = d.data(:,3); % y vel

	% save peak to peak value for ldv
	p2pldv(fnum,i) = max(sig) - min(sig);

	% get fourier transform data
	%[ftformy_t, fpeaksy_t] = CalcFourierTransform(t,sig);
	%freqvals(i) = fpeaksy_t(1,1)*1e-3; % replace the orig freq
	%p2pldv(fnum,i) = fpeaksy_t(1,2);
end % end ldv txt file loop

%*************************************************************%
% FBG %
%*************************************************************%
BW=1588*10^-9                              % Bragg wavelength
pe=0.22                                    % photo-elastic constant

%file=dir('*.csv');                           % Find csv files in the folder list folder content
%filecount=length(file);                      % number of CSV files in the folder
% fnum=1:Remote, fnum=2:Direct
for fnum=1:2
%for fnum=2

	if fnum==1
		%fldr='20190619_Remote/'
		%fldr='20190719_RemoteSinglePoint2/'
		fldr='20190801_RemoteSinglePoint3/'
		%FBGcurve=strcat(fldr,'scope_0.csv'); % remote, remote2
		FBGcurve=strcat(fldr,'scope_0_1.csv'); % remote3
	else
		fldr='20190626_Direct/'
		%fldr='20190719_RemoteSinglePoint2/'
		FBGcurve=strcat(fldr,'scope_0.csv'); % direct
	end
	
	% read FBG spectrum (its file name should be written such that MATLAB reads it first)
	%FBGcurve=file(1).name; 
	FBGdata=csvread(FBGcurve,2,0);

	%figure('units','normalized','outerposition',[0 0 1 1])      % create a window for plotting
	%for i=2:filecount
	filecount=15

	% loop all frequenices - each has a single csv file from FBG laser and svd/mat from LDV
	for i=1:filecount
		%s=file(i).name;                           
		if fnum==1
			%s=strcat(fldr,'scope_',num2str(i),'.csv'); % remote, remote2
			s=strcat(fldr,'scope_',num2str(i),'_1.csv'); % remote3
		else
			s=strcat(fldr,'scope_',num2str(i),'.csv'); % remote2, direct
		end
		
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

		% get fourier transform info
		%[ftformy_t, fpeaksy_t] = CalcFourierTransform(time(:,:),FilteredGraph(:,i));
		%freqvals(i)
		%[d, idxclos] = min(abs(ftformy_t(:,1) - freqvals(i)*1e3)); % get closest index
		%p2pfbg(fnum,i) = ftformy_t(idxclos,2); % closest index / match
		%ftformy_t(idxclos,1)
		%ftformy_t(idxclos,2)
		%p2pfbg(fnum,i) = fpeaksy_t(1,2); % peak mag
		%fpeaksy_t(1,1)
		%fpeaksy_t(1,2)

	end % end fbg csv file loop
end % end fnum (direct or remote) loop

%*************************************************************%
% Plot %
%*************************************************************%

% calculate wavelength
wavespeed = 5110*1e3; % mm/s
fbglen = 10; % 10mm = 1cm
freqvalshz = freqvals*1e3; % convert kHz to Hz
lambdavals = (wavespeed ./ freqvalshz) / fbglen;

% calculate normalized strain for remote and direct
p2pldvremnorm = p2pldv(1,:) ./ p2pldv(1,1);
%plotvalsrem = p2pfbg(1,:) ./ p2pldv(1,:);
plotvalsrem = p2pfbg(1,:) ./ p2pldvremnorm;
%plotvalsrem =  p2pldvremnorm ./ p2pfbg(1,:);

%plotvalsdir = p2pfbg(2,:) ./ p2pldv(2,:);
%plotvalsdir = p2pfbg(2,:) ./ p2pldv(1,:); % using remote ldv
plotvalsdir = p2pfbg(2,:) ./ p2pldvremnorm; % using remote ldv
%plotvalsdir =  p2pldvremnorm ./ p2pfbg(2,:); % using remote ldv

% plot
%plot(lambdavals,plotvalsrem,'r.-','MarkerSize',25,'DisplayName','Remote','LineWidth',1.5);
semilogx(lambdavals,plotvalsrem,'r.-','MarkerSize',25,'DisplayName','Remote','LineWidth',1.5);
hold on; grid on;
%plot(lambdavals,plotvalsdir,'b.-','MarkerSize',25,'DisplayName','Direct','LineWidth',1.5);
semilogx(lambdavals,plotvalsdir,'b.-','MarkerSize',25,'DisplayName','Direct','LineWidth',1.5);

xlim([0.1 10]);

ylabel('Normalized FBG [\mu\epsilon]');
%ylabel('reflectivity normalized by input');
%xlabel('frequency [kHz]');
xlabel('\lambda / L');

% label point where curve starts to go down
%text(lambdavals(9),plotvalsrem(9)+.01,strcat(num2str(freqvals(9)),' kHz'),'FontSize',16);

title('Remote FBG and Direct FBG normalized with LDV (Input)');
%title('Remote FBG and Direct FBG normalized with LDV (Input): DFT Peaks');
%title('Remote FBG and Direct FBG normalized with LDV (Input): DFT Match');
%title('Reflectivity vs Wavelength / FBG length ratio: Remote2 Before Bond');
%title('Reflectivity vs Wavelength / FBG length ratio: Remote2 After Bond');
%title('Reflectivity vs Wavelength / FBG length ratio: Remote and Direct');
%title('Reflectivity vs Wavelength / FBG length ratio: Remote and Direct with Remote2');

set(gca,'FontSize',18);
legend('show','Location','Northwest');
%set(gca,'xdir','reverse');

