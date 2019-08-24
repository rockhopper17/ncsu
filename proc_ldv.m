clear all; clc; close all;

% folder containing txt files from ldv
%fldr = '20190719_RemoteSinglePoint2/'
%fldr = '20190801_RemoteSinglePoint4/'
%fldr = '20190626_Direct/'
%fldr = '20190801_RemoteSinglePoint3/'
fldr = '20190808_LDVOnlyRemote/'
%fldr = '20190808_LDVOnlyRemote2/'

% powerpoint creation
%pptfname = 'remote2_ldv_beforebond';
%pptfname = 'remote2_ldv_afterbond';
%import mlreportgen.ppt.*;
%slides = Presentation(pptfname);

% frequency values measured
freqvals=(300:50:1000);
%freqvals=[300:50:550,600:10:790,800:50:1000]; % LDVOnly_Remote2
filecount = numel(freqvals);

% xtick labels with wavelength ratio
xtickfreqs = [300:100:1000];
wavespeed = 5110*1e3; % mm/s
fbglen = 10; % 10mm = 1cm
freqvalshz = xtickfreqs*1e3; % convert kHz to Hz
xtickratio = round((wavespeed ./ freqvalshz) / fbglen, 2);
for i=1:numel(xtickfreqs)
	xlabels{i} = strcat(num2str(xtickfreqs(i)),' (',num2str(xtickratio(i)),')');
end

% loop all frequencies and pull data from txt file
%figure;
%figure('units','inches','position',[3 3 10 12]);
figure('units','inches','position',[3 3 20 12]); % CalcFourierTransform
for i=1:filecount
%for i=1:2:filecount
	fname = string(sprintf('%04d',freqvals(i)));

	% *** txt: single point scan *** %
	%txtfile = strcat(fldr,fname,'_BeforeBond.txt');
	%txtfile = strcat(fldr,fname,'_AfterBond.txt');
	txtfile = strcat(fldr,fname,'.txt');
	d = importdata(txtfile);
	t = d.data(:,1); % time
	sig = d.data(:,3); % y vel
	%sig = d.data(:,4); % z vel
	% ********** %

	% *** svd: line scan *** %
	%pos = 12; 
	%matfile = strcat(fldr,fname,'.mat');
	%load(matfile);
	%sig = amp_y(pos,:); % y vel
	%sig = amp_z(pos,:); % z vel
	% ********** %

	% get peak to peak value
	p2pldv(i) = max(sig) - min(sig);

	% get fourier transform sample rate
	%numt = length(t); % number of data points
	%dt = mean(diff(t));
	%fs = 1 / dt; % sample rate
	
	% plot velocity vs time for each frequency
	%subplot(8,2,i);
	%%subplot(8,1,ceil(i/2));
	%plot(t*1e6, sig*1e3,'DisplayName','y vel','LineWidth',1.5);
	%hold on; grid on; box on;
	%title(sprintf('%d kHz (%0.3f peak-to-peak)',freqvals(i),p2pldv(i)*1e3));
	%ylabel('mm/s');
	%xlabel('\mus');
	%%axis([10 40 -3 3]); % remote2
	%axis([10 40 -15 15]); % ldvonly
	%%axis([10 40 -20 20]); % remote3
	%%axis([20 60 -4 4]);

	% plot pwelch
	%[pxx,f] = pwelch(sig,[],[],[],fs);
	%idxstop = min(find(f*1e-3 >= 1200)); % get index for first value >= 1200 kHz
	%ftform(:,i) = f;
	%subplot(8,2,i);
	%plot(f(1:idxstop)*1e-3,10*log10(pxx(1:idxstop)));
	%xlabel('Frequency (Hz)')
	%ylabel('PSD (dB/Hz)')

	% plot fft
	%ft = fft(sig);
	%P2 = abs(ft/numt);
	%P1 = P2(1:numt/2+1);
	%P1(2:end-1) = 2*P1(2:end-1);
	%f = (fs*(0:(numt/2))/numt)*1e-3;
	%idxstop = min(find(f >= 1200)); % get index for first value >= 1200 kHz
	%subplot(8,2,i);
	%plot(f(1:idxstop),P1(1:idxstop)) 
	%title('Single-Sided Amplitude Spectrum of X(t)')
	%xlabel('f (Hz)')
	%ylabel('|P1(f)|')

	% plot CalcFourierTransform
	[ftformy_t, fpeaksy_t] = CalcFourierTransform(t,sig);
	ftform = struct('freqidx',i,'freq',ftformy_t(:,1),'mag',ftformy_t(:,2),...
			'peakfreq',fpeaksy_t(:,1),'peakmag',fpeaksy_t(:,2));
	ftformall(i) = ftform;
	freq = [ftform.freq]*1e-3; % Hz to kHz
	mag = [ftform.mag]*1e3; % m/s to mm/s
	peakfreq = [ftform.peakfreq]*1e-3;
	peakmag = [ftform.peakmag]*1e3;
	fres = freq(3) - freq(2);
	subplot(4,4,i);
	plot(freq,mag);
	grid on;
	%text(peakfreq(1)+200,peakmag(1)-0.03,num2str(peakfreq(1)),'FontSize',16);
	title(sprintf('%d (%.f) kHz',freqvals(i),peakfreq(1)));
	ylabel('[mm/s]');
	xlabel('[kHz]');
	xlim([0 2000]);

	% save to powerpoint
	%imgname = sprintf('%sldv_%d.jpg',fldr,freqvals(i));
	%saveas(gcf,imgname);
	%img = Picture(imgname);
	%img.Width = '10.5in';
	%img.Height = '7.5in';
	%slide = add(slides,'Blank');
	%add(slide,img);

end % end ldv txt file loop

% normalize by 300 kHz value
%plotvals = p2pldv(:) ./ p2pldv(1);

% plot: convert time to microseconds and velocity to mm/s
%plot(freqvals, plotvals, '.-','LineWidth',1.5,'MarkerSize',15);
%hold on;
%grid on;
%title('LDV (Input): Normalized Velocity vs Frequency');
%ylabel('');
%xlabel('kHz (\lambda / L)');
%set(gca,'FontSize',16);
%xticks(xtickfreqs);
%xticklabels(xlabels);

% subplot title
sgtitle('LDV (Input): Fourier Transform with CalcFourierTransform');
%sgtitle('LDV (Input)');
%sgtitle('Remote2 LDV After Bond');
%sgtitle('Remote3 LDV');
%close(slides);
