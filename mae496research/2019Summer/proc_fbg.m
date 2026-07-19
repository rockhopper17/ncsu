clear all; clc; close all;

% powerpoint creation
%pptfname = 'remote2_fbg';  % powerpoint file name
%pptfname = 'remote1_fbg';  % powerpoint file name
%pptfname = 'remote_fbg';  % powerpoint file name

%import mlreportgen.ppt.*;
%slides = Presentation(pptfname);

% frequency values measured
freqvals = (300:50:1000);
filecount = numel(freqvals);

% fbg settings from John's code
BW=1588*10^-9                              % Bragg wavelength
pe=0.22                                    % photo-elastic constant

figure('units','inches','position',[3 3 20 12]); % CalcFourierTransform

% fnum=1:Remote, fnum=2:Direct
%for fnum=1
for fnum=1:2
	if fnum==1
		%fldr='20190619_Remote/'
		%fldr='20190719_RemoteSinglePoint2/'
		fldr='20190801_RemoteSinglePoint3/'
		%FBGcurve=strcat(fldr,'scope_0.csv'); % remote2
		FBGcurve=strcat(fldr,'scope_0_1.csv'); % remote3
	else
		fldr='20190626_Direct/'
		%fldr='20190719_RemoteSinglePoint2/'
		FBGcurve=strcat(fldr,'scope_0.csv'); % direct
	end
	
	FBGdata=csvread(FBGcurve,2,0);

	% loop all frequenices - each has a single csv file from FBG laser and svd/mat/txt from LDV
	for i=1:filecount
	%for i=1:2:filecount
		disp(freqvals(i));

		if fnum==1
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
		p2pfbg(i) = (max(FilteredGraph(:,i)) - min(FilteredGraph(:,i)))*1000000;

		% plot the fbg waveform
		%figure;
		%subplot(8,2,i);
		%%subplot(8,1,ceil(i/2));
		%plot(time(:,:)*1000000,FilteredGraph(:,i)*1000000,'k-', 'LineWidth',2);
		%%title(sprintf('%d kHz',freqvals(i)));
		%title(sprintf('%d kHz (%0.3f peak-to-peak)',freqvals(i),p2pfbg(i)));
		%xlabel('\mus');
		%ylabel('\mu\epsilon');
		%%set(gca,'FontSize',40);
		%set(gca,'LineWidth',1.5);
		%set(gca,'XTickLabel',[]);
		%%axis([60 80 -1.3 1.3]); % remote2
		%%axis([60 80 -1 1]); % remote3
		%axis([30 50 -.7 .7]); % direct
		%grid on
		%box on
		%set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');

		% plot CalcFourierTransform
		[ftformy_t, fpeaksy_t] = CalcFourierTransform(time(:,:),FilteredGraph(:,i));
		ftform = struct('freqidx',i,'freq',ftformy_t(:,1),'mag',ftformy_t(:,2),...
				'peakfreq',fpeaksy_t(:,1),'peakmag',fpeaksy_t(:,2));
		ftformall(i) = ftform;
		freq = [ftform.freq]*1e-3; % Hz to kHz
		mag = [ftform.mag]*1e3; % m/s to mm/s
		peakfreq = [ftform.peakfreq]*1e-3;
		peakmag = [ftform.peakmag]*1e3;
		fres = freq(3) - freq(2);
		subplot(4,4,i);
		hold on; grid on;
		if fnum==1
			plot(freq,mag*1e6,'r-','DisplayName','Remote');
			peakfreqrem(i) = peakfreq(1);
		else
			plot(freq,mag*1e6,'b-','DisplayName','Direct');
			title(sprintf('%d (Rem=%.f, Dir=%.f) kHz',freqvals(i),peakfreqrem(i),peakfreq(1)));
			if i==1
				legend show;
			end
		end
		%text(peakfreq(1)+200,peakmag(1)*1e6-3,num2str(peakfreq(1)),'FontSize',16);
		ylabel('[\mu\epsilon]');
		xlabel('[kHz]');
		xlim([0 2000]);

		% create image of plot and save to powerpoint
		%imgname = sprintf('%sfbg_%d.jpg',fldr,freqvals(i));
		%saveas(gcf,imgname);
		%img = Picture(imgname);
		%img.Width = '10.5in';
		%img.Height = '7.5in';
		%slide = add(slides,'Blank');
		%add(slide,img);

	end % end fbg csv file loop
end % end fnum (direct or remote) loop

% normalize by 300 kHz value
%plotvals = p2pfbg(:) ./ p2pfbg(1);

% plot: convert time to microseconds and velocity to mm/s
%plot(freqvals, plotvals, 'k.-','LineWidth',1.5,'MarkerSize',15);
%hold on;
%grid on;
%title('FBG: Normalized Microstrain vs Frequency, Remote');
%title('FBG: Normalized Microstrain vs Frequency, Direct');
%ylabel('');
%xlabel('kHz');

sgtitle('Remote and Direct FBG: Fourier Transform with CalcFourierTransform','FontSize',16);
%sgtitle('Remote FBG','FontSize',16);
%sgtitle('Direct FBG','FontSize',16);
%saveas(gcf,'direct_fbg2.jpg');
%close(slides);

