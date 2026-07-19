% Code for processing svd data file from PolyTec
function ProcessSvdPlots(fnames, plotnum, veldir, roworcol, isrotate, npos, savetype)
%
% ProcessSvdPlots 
%
% inputs:
%	fnames:		svd file name(s)
%	plotnum:	number for which plot to create
% 		1 = map of point nums with row/col
% 		2 = column plots of magnitude for all points in column
% 		2 = heat map with each point showing avg of magnitudes over full time range
% 		3 = column avg/max/row and total avg/max *** creates 4 main plots
% 		4 = column value for each pt in a row *** creates 5th main plot
% 		5 = presentation plots: time-domain, freq-domain, and time-freq domains
% 		6 = fourier transform with 3 peaks
%	npos:		
%
% outputs:
%	ftform:		fourier transform frequencies and magnitudes

% see if mat file already exists, otherwise create it
matfile = strcat('mat/',fnames(1),'.mat');
if isfile(matfile)
	load(matfile);
else
	ExportData(fnames);
end

svdtitle = fnames(1);

% thick horns
%load('mat/svddata_ab4thick_ft.mat'); % alum horn a/b=4
	%svdtitle = 'ab4thick';
	%npos = 397;
%load('svddata_4_y_CWT.mat'); % alum horn a/b=4 y
%load('svddata_2_x_CWT.mat'); % alum horn a/b=2 x
%load('svddata_exp4_y_CWT.mat'); % alum horn a/b= exp 4 y

% thin horns
%load('mat/svddata_ab4thin_ft.mat'); % alum horn a/b=4
	%svdtitle = 'ab4thin';
	%npos = 374;

% get video image data for plotting as background
xImg = linspace(min(x), max(x), size(imageData, 2));
yImg = linspace(min(y), max(y), size(imageData, 1));

% movie/ppt properties
runtime = 55;  % num seconds to run movie
movfname = 'procsvdmovie_300kHz_bycolumn.avi';  % movie file name
pptfname = 'alumhorn_4_y_allrows';  % powerpoint file name
frate = numt/runtime;  % frame rate for movie file
%frate = 1;

% set window size
%set(gcf,'units','inches','position',[1 1 13.33 7.5],'InvertHardCopy','off');
set(gcf,'units','normalized','outerposition',[0.1 0.1 0.8 0.8]);
%set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
colormap('jet');

%*****************************************************************************%
%plotnum = 5
makemovie = false;  % flag for making a movie (can be slow)
makeppt = false; % flag for making a powerpoint
%*****************************************************************************%

% setup movie
if makemovie == true
	writerObj = VideoWriter(movfname);
	writerObj.FrameRate = frate;
	open(writerObj);
end

% powerpoint
if makeppt == true
	import mlreportgen.ppt.*;
	slides = Presentation(pptfname);
end

%==============================================================================
if plotnum == 1
	% plot points as their index number
	scatter(x, y, [], 'w');
	hold on; grid on;
	image(xImg, yImg, imrotate(flipdim(imageData,1),90), 'CDataMapping', 'scaled'); % ab4
	%image(xImg, yImg, imageData, 'CDataMapping', 'scaled');
	%image(xImg, yImg, imrotate(imageData,180), 'CDataMapping', 'scaled'); % ab2x
	%axis([-1 38 0 20]);
	set(gcf,'units','normalized','outerposition',[0 0 1 1]); % full screen
	set(gca,'Color', [0.7,0.7,0.7]);
	%set(gca, 'XDir','reverse');

	% get colormap for making all lines different colors
	%cmap = jet(numel(ypts));
	cmap = jet(numel(xpts));

	for ptidx = 1:numpts
		xidx = find(xpts == x(ptidx)); % column number
		yidx = find(ypts == y(ptidx)); % row number
		%xidx = find(xpts == round(x(ptidx))); % column number
		%yidx = find(ypts == round(y(ptidx))); % row number

		text(x(ptidx),y(ptidx),sprintf('%d\nr%dc%d',ptidx,yidx,xidx),'Color', cmap(xidx,:));
		%text(x(ptidx),y(ptidx),sprintf('%d',ptidx,yidx,xidx),'Color', cmap(yidx,:));
	end

	%saveas(gca,['jpg/' svdtitle '_map.jpg']);

%==============================================================================
elseif plotnum == 2
	% get colormap for making all lines different colors
	cmap = jet(numel(ypts));

	% loop columns
	for xidx = 1:numel(xpts)
	%for xidx = [1 29 50]
	%for xidx = [29]
		%figure;
		subplot(3,1,[1:2]);

		% get indexes of all points in current column
		ptsidx = find(x == xpts(xidx));

		% plot time-frequency for each point in this column
		for ptidx = ptsidx(1):ptsidx(end)
			% get row of this point so we can keep row colors consistent
			yidx = find(ypts == y(ptidx));

			% plot
			plot(t*1e6, sigxt(ptidx,:), 'Color', cmap(yidx,:), 'DisplayName', ['pt ' num2str(ptidx)],...
				'LineWidth',2);
			hold on;
		end

		set(gca,'Color', [0.7,0.7,0.7], 'FontSize',14);
		%title(sprintf('Rectangle 300 kHz magnitude, bump cwt, column %d, all points',xidx), 'FontSize',14);
		title(sprintf('300 kHz magnitude, bump cwt, column %d, all points',xidx), 'FontSize',14);
		ylabel('magnitude','FontSize',14);
		xlabel('time [\mus]','FontSize',14);
		%axis([0 250 0 0.075]); % horn
		%axis([0 250 0 0.01]); % rect
		legend('FontSize',14);
		%legend show;
		grid on;
		hold off;

		% highlight all points in current column
		cmap = jet(numel(ypts));
		sigxtcol = zeros(1,numpts);
		for r = 1:numel(ypts)
			yidx = find(y == ypts(r)); % row number
			sigxtcol(yidx) = r;
		end
		%sigxtcol(ptsidx) = 27; % horn has 27 rows
		sigxtcol(ptsidx) = 25; % rect has 25 rows

		% scatter plot with column highlighted
		subplot(3,1,3);
		hold on; grid on;
		set(gca,'Color', [0.7,0.7,0.7], 'FontSize',14);
		%image(xImg, yImg, imageData, 'CDataMapping', 'scaled');
		image(xImg, yImg, imrotate(flipdim(imageData,1),90), 'CDataMapping', 'scaled'); % ab4y
		scatter(x, y, [], sigxtcol, 'filled');
		ylabel('y position [mm]','FontSize',14);
		xlabel('x position [mm]','FontSize',14);
		%axis([-1 40 0 20]); % horn
		axis([-2 40 0 20]); % rect
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		elseif makeppt == true
			imgname = sprintf('col%d.jpg',xidx);
			saveas(gcf,imgname);
			img = Picture(imgname);
			%img.Width = '13.33in';
			img.Width = '10.5in';
			img.Height = '7.5in';
			%img.Width = '1400px';
			%img.Height = '1000px';
			slide = add(slides,'Blank');
			add(slide,img);
		end
	end


elseif plotnum == 6
	% get num per peak
	pknum = 1;
	peakfreq = [ftform.peakfreq]; % row 1 = top peak, row 2 = 2nd, row 3 = 3rd for all points (in cols)
	upeaks = unique(peakfreq(pknum,:)); % get all the unique frequences for top peak
	numpeaks = length(upeaks); % total number of peak frequencies
	numatpeak = zeros(numpeaks,1); % will hold the number of points having that peak freq
	for pkidx = 1:numpeaks
		numatpeak(pkidx) = sum(peakfreq(pknum,:) == upeaks(pkidx)); % count of pts per peak
	end

	% scatter plot map
	subplot(3,1,[1:2]);
	hold on; grid on;
	set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	colormap(gca,'jet');
	
	% horn image and axis limits, specific to horn or orientation %
	image(xImg, yImg, imrotate(flipdim(imageData,1),90), 'CDataMapping', 'scaled'); % ab4 thick
	caxis([280 350]); % ab4 thick
	%image(xImg, yImg, imrotate(imageData,180), 'CDataMapping', 'scaled'); % ab2x
	%image(xImg, yImg, imageData, 'CDataMapping', 'scaled'); % abexp4y

	% plot frequency peaks
	scatter(x, y, 100, peakfreq(pknum,:)*1e-3, 's','filled');
	title([svdtitle ' fourier transform frequency peak']);
	ylabel('y position [mm]');
	xlabel('x position [mm]');
	c = colorbar;
	c.Label.String = 'frequency at peak [kHz]';

	% bar chart
	subplot(3,1,3);
	hold on; grid on;
	set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	bar(upeaks*1e-3,numatpeak);
	ylabel('count of points');
	xlabel('frequency [kHz]');
	
	set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
	saveas(gca,['jpg/' svdtitle '_freqpeak.jpg']);


elseif plotnum == 5

	% get vel signal
	%sigx = amp_x(npos,:);
	sigx = amp_y(npos,:);

	% time-domain
	plot(t*1e6, sigx*1e3);
	grid on;
	title([svdtitle ' time-domain for y velocity at point ' num2str(npos) ' (raw data)']);
	ylabel('y-velocity [mm/s]','FontSize',24);
	xlabel('time [\mus]','FontSize',24);
	set(gca,'FontSize',24);
	%set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	saveas(gca,['jpg/' svdtitle '_xvel_' num2str(npos) '.jpg']);
	drawnow

	% frequency-domain
	figure;
	set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');

	%subplot(2,1,1);
	freq = [ftform.freq]*1e-3; % Hz to kHz
	mag = [ftform.mag]*1e3; % m/s to mm/s
	peakfreq = [ftform.peakfreq]*1e-3;
	peakmag = [ftform.peakmag]*1e3;

	fres = freq(3,npos) - freq(2,npos);

	plot(freq(:,npos),mag(:,npos));
	text(peakfreq(1,npos),peakmag(1,npos),num2str(peakfreq(1,npos)),'FontSize',24);
	text(peakfreq(2,npos),peakmag(2,npos),num2str(peakfreq(2,npos)),'FontSize',24);
	text(peakfreq(3,npos),peakmag(3,npos),num2str(peakfreq(3,npos)),'FontSize',24);

	title([svdtitle ' manual fourier transform at point ' num2str(npos) ', fres=' num2str(fres) ' kHz']);
	ylabel('magnitude [mm/s]');
	xlabel('frequency [kHz]');
	set(gca,'FontSize',24);
	
	%subplot(2,1,2);
	%pwelch(sigx,[],[],[],Fs);
	%title([svdmatname([9,11]) ' Welch Power Spectral Density Estimate: Point ' num2str(npos)]);
	%set(gca,'FontSize',24);
	%set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);

	saveas(gca,['jpg/' svdtitle '_freq_' num2str(npos) '.jpg']);
	drawnow

	% STFT
	figure;
	set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
	colormap('jet');
	pspectrum(sigx,Fs,'spectrogram','FrequencyLimits',[0 1000e3]);
	title([svdtitle ' time-frequency domain point ' num2str(npos) ': pspectrum, default']);
	set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	colorbar;
	saveas(gca,['jpg/' svdtitle '_pspectrum_' num2str(npos) '.jpg']);
	drawnow

	%figure;
	%set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
	%colormap('jet');
	%pspectrum(sigx,Fs,'spectrogram','FrequencyLimits',[0 1000e3],'FrequencyResolution',11e3);
	%title('time-frequency domain point 726: pspectrum, Frequency Resolution = 11e3');
	%set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	%colorbar;

	%figure;
	%set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
	%colormap('jet');
	%pspectrum(sigx,Fs,'spectrogram','FrequencyLimits',[0 1000e3],'TimeResolution',1e-6);
	%title('time-frequency domain point 726: Time Resolution = 1e-6');
	%set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	%colorbar;

	% CWT
	figure;
	set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
	colormap('jet');
	cwt(sigx,Fs,'FrequencyLimits',[0 1000e3]);
	title([svdtitle ' time-frequency domain point ' num2str(npos) ': cwt, default Morlet']);
	set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	colorbar;
	saveas(gca,['jpg/' svdtitle '_cwt_morlet_' num2str(npos) '.jpg']);
	drawnow

elseif plotnum == 4
	% row number to plot
	%rownum = 13; % _4_y

	% hard code all points in row 10 for misaligned horn
	%rownum = 11; % _2_x
	%ptsidxrow11 = [1052 1025 998 971 944 917 890 863 836 809 782 755 728 701 674 647 620 593 ...
		%566 539 512 485 458 432 409 390 373 358 345 332 319 306 293 280 267 254 241 228 215 ...
		%202 189 176 163 150 137 124 111 98 85 72 59 46 33 20 7];

	for rownum = 1:27
	%for rownum = 13:13

		% get all points in row	
		ptsidxrow = find(y == ypts(rownum));
		%ptsidxrow = [375 376 349 322 323 324]; % specific points to plot

		% get num cols
		numcols = numel(xpts);
		numpts = numel(ptsidxrow);
		%numcols = numel(ptsidxrow11);

		% get colormap for making all lines different colors
		cmap = jet(numcols);

		% row data
		%sigxtrow = zeros(numcols,numt);
		sigxtrow(1:numpts,:) = sigxt(ptsidxrow,:);
		
		% hold color map for scatter, and highlight points
		sigxtcol = zeros(1,numcols);
		%rowpts = zeros(1,numcols);

		% loop columns
		for xidx = 1:numcols
		%for xidx = [1 29 50]
		%for xidx = [29]
			% get indexes of all points in current column and row
			ptsidx = find(x == xpts(xidx));
			%ptsidx = find(round(x) == xpts(xidx));  % 2_x
			%ptsidxrow = find(x == xpts(xidx) & y == ypts(rownum));
			%ptsidxrow = ptsidxrow11(xidx);

			% get pt in row
			%sigxtrow(xidx,:) = sigxt(ptsidxrow,:);

			% set colors for scatter plot
			sigxtcol(ptsidx) = xidx;
			%rowpts(xidx) = ptsidxrow;
			
			%xidx
		end

		%ptsidxrow = ptsidxrow11;

		figure;
		set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
		colormap('jet');

		% loop all points in row
		%for xidx = 1:numel(ptsidxrow)
		%for xidx = 1:numel(rowpts)
		for xidx = 1:numpts
		%for xidx = [1 29 50]
		%for xidx = [29]
			%figure;
			subplot(3,1,[1:2]);

			% plot
			%plot(t*1e6, sigxt(ptsidxrow(xidx),:), 'Color', cmap(sigxtcol(ptsidxrow(xidx)),:),'LineWidth',2);
			%plot(t*1e6, sigxt(rowpts(xidx),:), 'Color', cmap(sigxtcol(rowpts(xidx)),:),'LineWidth',2);
			plot(t*1e6, sigxtrow(xidx,:), 'Color', cmap(sigxtcol(ptsidxrow(xidx)),:),'LineWidth',2);
			%title([svdmatname([9,11]) ' 300 kHz magnitude, bump cwt, all columns, row ' num2str(rownum)]);
			title([svdmatname([9,11]) ' peak 1 magnitude, Morlet cwt, all columns, row ' num2str(rownum)]);

			hold on;
		end

		% configure plot
		set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
		curtick = get(gca, 'YTick');
		set(gca, 'YTickLabel', cellstr(num2str(curtick(:))));
		ylabel('magnitude','FontSize',24);
		xlabel('time [\mus]','FontSize',24);
		grid on;
		hold off;

		% scatter plot map
		subplot(3,1,3);
		hold on; grid on;
		set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
		%image(xImg, yImg, imageData, 'CDataMapping', 'scaled');
		image(xImg, yImg, imrotate(flipdim(imageData,1),90), 'CDataMapping', 'scaled'); % ab4y
		scatter(x, y, [], sigxtcol, 'filled');
		%plot(x(ptsidxrow), y(ptsidxrow), 'or', 'MarkerSize', 10, 'LineWidth',2);
		plot(x(ptsidxrow), y(ptsidxrow), 'or', 'MarkerSize', 10, 'LineWidth',2);
		ylabel('y position [mm]','FontSize',24);
		xlabel('x position [mm]','FontSize',24);
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		elseif makeppt == true
			imgname = sprintf('%s_row%d.jpg',svdmatname(1:end-4),rownum);
			saveas(gcf,imgname);
			img = Picture(imgname);
			%img.Width = '13.33in';
			img.Width = '10.5in';
			img.Height = '7.5in';
			%img.Width = '1400px';
			%img.Height = '1000px';
			slide = add(slides,'Blank');
			add(slide,img);
		else
			% save jpg
			saveas(gcf,[svdmatname(1:end-4) '_row' num2str(rownum) '.jpg']);
		end

	end

elseif plotnum == 3
	% get colormap for making all lines different colors
	cmap = jet(numel(xpts));

	% get num cols
	numcols = numel(xpts);

	% max/avg data
	sigxtmax = zeros(numcols,numt);
	sigxtavg = zeros(numcols,numt);
	sigtmax = zeros(1,numt);
	sigtavg = zeros(1,numt);
	
	% hold color map for scatter, and highlight points
	sigxtcol = zeros(1,numcols);
	hpts = zeros(1,numt);

	% loop columns
	for xidx = 1:numcols
	%for xidx = [1 29 50]
	%for xidx = [29]
		% get indexes of all points in current column
		ptsidx = find(x == xpts(xidx));
		%ptsidx = find(round(x) == xpts(xidx));

		% get max/avg for the column
		sigxtmax(xidx,:) = max(sigxt(ptsidx,:));
		sigxtavg(xidx,:) = mean(sigxt(ptsidx,:));

		% set colors for scatter plot
		sigxtcol(ptsidx) = xidx;
		
		xidx
	end

	% get total max/avg
	[sigtmax,hpts] = max(sigxt(:,:));
	sigtavg = mean(sigxt(:,:));

	% 1 = avg, 2 = max, 3 = all col avg, 4 = all col max
	for ptype = 1:4
		figure(ptype);
		set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
		colormap(gcf,'jet');

		% loop columns
		for xidx = 1:numcols
		%for xidx = [1 29 50]
		%for xidx = [29]
			%figure;
			subplot(3,1,[1:2]);

			% plot
			if ptype == 1
				plot(t*1e6, sigtavg,'-k','LineWidth',2);
				title([svdtitle ' Morlet CWT, top peak, all points, avg']);
			elseif ptype == 2
				plot(t*1e6, sigtmax,'-k','LineWidth',2);
				title([svdtitle ' Morlet CWT, top peak, all points, max']);
			elseif ptype == 3
				plot(t*1e6, sigxtavg(xidx,:), 'Color', cmap(xidx,:),'LineWidth',2);
				title([svdtitle ' Morlet CWT, top peak, all columns, avg']);
			elseif ptype == 4
				plot(t*1e6, sigxtmax(xidx,:), 'Color', cmap(xidx,:),'LineWidth',2);
				title([svdtitle ' Morlet CWT, top peak, all columns, max']);
			end

			hold on;
		end

		% configure plot
		set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
		curtick = get(gca, 'YTick');
		set(gca, 'YTickLabel', cellstr(num2str(curtick(:))));
		ylabel('magnitude','FontSize',24);
		xlabel('time [\mus]','FontSize',24);
		grid on;
		hold off;

		% scatter plot map
		subplot(3,1,3);
		hold on; grid on;
		set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
		%image(xImg, yImg, imageData, 'CDataMapping', 'scaled');
		%image(xImg, yImg, imrotate(imageData,180), 'CDataMapping', 'scaled'); % ab2x
		image(xImg, yImg, imrotate(flipdim(imageData,1),90), 'CDataMapping', 'scaled'); % ab4y, ab4expy
		scatter(x, y, [], sigxtcol, 'filled');
		if ptype == 2
			plot(x(hpts), y(hpts), 'or', 'MarkerSize', 10, 'LineWidth',2);
		end
		ylabel('y position [mm]','FontSize',24);
		xlabel('x position [mm]','FontSize',24);
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		elseif makeppt == true
			imgname = sprintf('col%d.jpg',xidx);
			saveas(gcf,imgname);
			img = Picture(imgname);
			%img.Width = '13.33in';
			img.Width = '10.5in';
			img.Height = '7.5in';
			%img.Width = '1400px';
			%img.Height = '1000px';
			slide = add(slides,'Blank');
			add(slide,img);
		else
			% save jpg
			saveas(gcf,['jpg/' svdtitle '_' num2str(ptype) '.jpg']);
		end
	end

elseif plotnum == 2

	sigxtavg = mean(sigxt');
	scatter(x, y, 300, sigxtavg, 's', 'filled');
	hold on;
	plot(x(npos), y(npos), 'or', 'MarkerSize', 20, 'LineWidth',5);  % highlight a point
	title(sprintf('300 kHz magnitude avg for each point'));
	xlabel('x position [mm]');
	ylabel('y position [mm]');
	colorbar;

end % plotnum

if makemovie == true
	%movie(M);
	close(writerObj);
elseif makeppt == true
	close(slides);
end

