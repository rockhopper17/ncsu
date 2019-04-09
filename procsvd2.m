% Code for processing svd data file from PolyTec

% clear all vars and plots
close all; clear all; clc;

%*****************************************************************************%
% load all workspace vars created from ExportData.m and ExportDataCWT.m
% variables in mat file, note that sizes are particular to test load
%    but variables will have same names
	 %>> whos
	  %Name               Size                   Bytes  Class     Attributes
	  %amp_x           1045x1500              12540000  double              
	  %amp_y           1045x1500              12540000  double              
	  %amp_z           1045x1500              12540000  double              
	  %fnames             1x1                      182  string              
	  %imageData       1742x3385x3            17690010  uint8               
	  %numf               1x1                        8  double              
	  %sigxt           1045x1500              12540000  double              
	  %sigxtpks        1045x1500              12540000  double              
	  %svdmatname         1x17                      34  char                
	  %t                  1x1500                 12000  double              
	  %usd_x              1x1                     4681  struct              
	  %usd_y              1x1                     4681  struct              
	  %usd_z              1x1                     4681  struct              
	  %xyz             1045x3                    25080  double  
%*****************************************************************************%

%load('svddata.mat'); % orig x_8cm test data
%load('svddata2.mat'); % orig x_8cm test data combined with scan plate

%load('svddata_horn.mat'); % test horn
%load('svddata_rect.mat'); % test rectangle

%load('svddata_horn2.mat'); % test horn with cwt data
%load('svddata_rect2.mat'); % test rectangle with cwt data

load('svddata_4_y_CWT.mat'); % alum horn a/b=4 y
%load('svddata_2_x_CWT.mat'); % alum horn a/b=2 x
%load('svddata_exp4_y_CWT.mat'); % alum horn a/b= exp 4 y

%svdtype = 'horn';
svdtype = 'aaaa';
%svdtype = 'rect';

npos = 726; % pt idx to highlight
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

% get video image data for plotting as background
xImg = linspace(min(x), max(x), size(imageData, 2));
yImg = linspace(min(y), max(y), size(imageData, 1));

% movie properties
makemovie = false;  % flag for making a movie (can be slow)
runtime = 55;  % num seconds to run movie
movfname = 'procsvdmovie_300kHz_bycolumn.avi';  % movie file name
%frate = N/runtime;  % frame rate for movie file
frate = 1;

% setup movie
if makemovie == true
	writerObj = VideoWriter(movfname);
	writerObj.FrameRate = frate;
	open(writerObj);
end

% powerpoint
makeppt = false;
if makeppt == true
	import mlreportgen.ppt.*;
	slides = Presentation('rrrRect300kHzCWTByColumn');
end

% set window size
%set(gcf,'units','inches','position',[1 1 13.33 7.5],'InvertHardCopy','off');
%set(gcf,'units','normalized','outerposition',[0.1 0.1 0.8 0.8]);
set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
colormap('jet');

%*****************************************************************************%
% cwt processed data, performed in ExportDataCWT.m
proccwt = false;
if proccwt == true
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
	sigxtsum = zeros(1,numpts);

	for ptidx = 1:numpts
		% pull out data for the single data point
		sigx = amp_x(ptidx,:);
		%sigx = sigx.*2;

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
end

%*****************************************************************************%
% 1 = column plots of magnitude for all points in column
% 2 = heat map with each point showing avg of magnitudes over full time range
% 3 = column avg/max/row and total avg/max *** creates 4 main plots
% 4 = column value for each pt in a row *** creates 5th main plot
% 5 = presentation plots: time-domain, freq-domain, and time-freq domains
plottype = 4
%*****************************************************************************%

if plottype == 5

	%npos = 726;
	%npos = 359; % 4_y
	npos = 349; % 4_y
	%npos = 320; % 2_x
	%npos = 412; % 4exp_y
	sigx = amp_x(npos,:);

	plot(t*1e6, sigx*1e3);
	grid on;
	title([svdmatname([9,11]) ' time-domain for x velocity at point ' num2str(npos) ' (raw data)']);
	ylabel('x-velocity [mm/s]','FontSize',24);
	xlabel('time [\mus]','FontSize',24);
	set(gca,'FontSize',24);
	%set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	saveas(gca,[svdmatname(1:end-4) '_xvel_' num2str(npos) '.jpg']);
	drawnow

	figure;
	set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
	pwelch(sigx,[],[],[],Fs);
	title([svdmatname([9,11]) ' Welch Power Spectral Density Estimate: Point ' num2str(npos)]);
	set(gca,'FontSize',24);
	%set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	saveas(gca,[svdmatname(1:end-4) '_pwelch_' num2str(npos) '.jpg']);
	drawnow

	% STFT
	figure;
	set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
	colormap('jet');
	pspectrum(sigx,Fs,'spectrogram','FrequencyLimits',[0 1000e3]);
	title([svdmatname([9,11]) ' time-frequency domain point ' num2str(npos) ': pspectrum, default']);
	set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	colorbar;
	saveas(gca,[svdmatname(1:end-4) '_pspectrum_' num2str(npos) '.jpg']);
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
	title([svdmatname([9,11]) ' time-frequency domain point ' num2str(npos) ': cwt, default Morlet']);
	set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	colorbar;
	saveas(gca,[svdmatname(1:end-4) '_cwt_morlet_' num2str(npos) '.jpg']);
	drawnow

	figure;
	set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
	colormap('jet');
	cwt(sigx,'bump',Fs,'FrequencyLimits',[0 1000e3]);
	title([svdmatname([9,11]) ' time-frequency domain point ' num2str(npos) ': cwt, bump']);
	set(gca,'Color', [0.7,0.7,0.7], 'FontSize',24);
	colorbar;
	saveas(gca,[svdmatname(1:end-4) '_cwt_bump_' num2str(npos) '.jpg']);
	drawnow

elseif plottype == 4
	% row number to plot
	rownum = 13; % _4_y
	% hard code all points in row 10 for misaligned horn
	%rownum = 11; % _2_x
	%ptsidxrow11 = [1052 1025 998 971 944 917 890 863 836 809 782 755 728 701 674 647 620 593 ...
		%566 539 512 485 458 432 409 390 373 358 345 332 319 306 293 280 267 254 241 228 215 ...
		%202 189 176 163 150 137 124 111 98 85 72 59 46 33 20 7];

	% get num cols
	numcols = numel(xpts);
	%numcols = numel(ptsidxrow11);

	% get colormap for making all lines different colors
	cmap = jet(numcols);

	% row data
	sigxtrow = zeros(numcols,numt);
	
	% hold color map for scatter, and highlight points
	sigxtcol = zeros(1,numcols);
	rowpts = zeros(1,numcols);

	% loop columns
	for xidx = 1:numcols
	%for xidx = [1 29 50]
	%for xidx = [29]
		% get indexes of all points in current column and row
		ptsidx = find(x == xpts(xidx));
		%ptsidx = find(round(x) == xpts(xidx));  % 2_x
		ptsidxrow = find(x == xpts(xidx) & y == ypts(rownum));
		%ptsidxrow = ptsidxrow11(xidx);

		% get pt in row
		sigxtrow(xidx,:) = sigxt(ptsidxrow,:);

		% set colors for scatter plot
		sigxtcol(ptsidx) = xidx;
		rowpts(xidx) = ptsidxrow;
		
		xidx
	end

	%ptsidxrow = ptsidxrow11;

	figure(1);
	set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
	colormap('jet');

	% loop all points in row
	%for xidx = 1:numel(ptsidxrow)
	for xidx = 1:numel(rowpts)
	%for xidx = [1 29 50]
	%for xidx = [29]
		%figure;
		subplot(3,1,[1:2]);

		% plot
		%plot(t*1e6, sigxt(ptsidxrow(xidx),:), 'Color', cmap(sigxtcol(ptsidxrow(xidx)),:),'LineWidth',2);
		plot(t*1e6, sigxt(rowpts(xidx),:), 'Color', cmap(sigxtcol(rowpts(xidx)),:),'LineWidth',2);
		%title([svdmatname([9,11]) ' 300 kHz magnitude, bump cwt, all columns, row ' num2str(rownum)]);
		title([svdmatname([9,11]) ' 300 kHz magnitude, Morlet cwt, all columns, row ' num2str(rownum)]);

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
	plot(x(rowpts), y(rowpts), 'or', 'MarkerSize', 10, 'LineWidth',2);
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
		saveas(gcf,[svdmatname(1:end-4) '_row' num2str(rownum) '.jpg']);
	end


elseif plottype == 3
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
		colormap('jet');

		% loop columns
		for xidx = 1:numcols
		%for xidx = [1 29 50]
		%for xidx = [29]
			%figure;
			subplot(3,1,[1:2]);

			% plot
			if ptype == 1
				plot(t*1e6, sigtavg,'-k','LineWidth',2);
				%title([svdmatname([9,11]) ' 300 kHz magnitude, bump cwt, all points, avg']);
				title([svdmatname([9,11]) ' 300 kHz magnitude, Morlet cwt, all points, avg']);
			elseif ptype == 2
				plot(t*1e6, sigtmax,'-k','LineWidth',2);
				%title([svdmatname([9,11]) ' 300 kHz magnitude, bump cwt, all points, max']);
				title([svdmatname([9,11]) ' 300 kHz magnitude, Morlet cwt, all points, max']);
			elseif ptype == 3
				plot(t*1e6, sigxtavg(xidx,:), 'Color', cmap(xidx,:),'LineWidth',2);
				%title([svdmatname([9,11]) ' 300 kHz magnitude, bump cwt, all columns, avg']);
				title([svdmatname([9,11]) ' 300 kHz magnitude, Morlet cwt, all columns, avg']);
			elseif ptype == 4
				plot(t*1e6, sigxtmax(xidx,:), 'Color', cmap(xidx,:),'LineWidth',2);
				%title([svdmatname([9,11]) ' 300 kHz magnitude, bump cwt, all columns, max']);
				title([svdmatname([9,11]) ' 300 kHz magnitude, Morlet cwt, all columns, max']);
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
			saveas(gcf,[svdmatname(1:end-4) '_' num2str(ptype) '.jpg']);
		end
	end

elseif plottype == 2

	sigxtavg = mean(sigxt');
	scatter(x, y, 300, sigxtavg, 's', 'filled');
	hold on;
	plot(x(npos), y(npos), 'or', 'MarkerSize', 20, 'LineWidth',5);  % highlight a point
	title(sprintf('300 kHz magnitude avg for each point'));
	xlabel('x position [mm]');
	ylabel('y position [mm]');
	colorbar;

elseif plottype == 1
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

end % plottype

if makemovie == true
	%movie(M);
	close(writerObj);
elseif makeppt == true
	close(slides);
end

