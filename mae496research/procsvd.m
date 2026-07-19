% clear all vars and plots
close all; clear all; clc;

%*****************************************************************************%
% different views
% 1 = scatter static view of positions to confirm general shape (can show idx nums)
% 2 = 3D scatter to view general shape and choose orientation for movie
% 3 = 3D scatter with animation and x vel vs time plot
% 4 = points in a line at certain y values (.0099 middle line plus others)
% 5 = avg x vel by x pos
% 6 = pwelch power spectral density estimates
% 7 = avg x vel, center x vel by x pos comparison horn to rect (4 subplots)
% 8 = 2D plot of max x vel at each point
% 9 = magnitudes of 300kHz (attempt to see wavefront)
% 10 = cwt (or contourf) movie for a chosen row
% 11 = x vel by x pos for chosen rows
% 12 = 300 kHz magnitudes by x pos for chosen rows (view 11 for cwt)
% 13 = x vel by y pos for chosen columns
% 14 = 300 kHz magnitudes by y pos for chosen columns (view 13 for cwt)
% 15 = cwt plots ***
% 16 = cwt with peaks horn animation (didn't show what was hoped for)
viewtype = 2
makemovie = false;  % flag for making a movie (can be slow)

% mat file name for data to import, after processing svd file with ExportData.m
%svdmatname = 'svddata.mat' % orig x_8cm test data (scan_time.svd)
%svdmatname = 'svddata2.mat' % orig x_8cm test data with plate data included (+scan_time_plate.svd)
%svdmatname = 'svddata_horn.mat' % orig horn (plastic)
%svdmatname = 'svddata_rect.mat' % orig rectangle (plastic)
%svdmatname = 'svddata_2_x.mat' % alum horn a/b=2
%svdmatname = 'svddata_4_y.mat' % alum horn a/b=4
%svdmatname = 'svddata_exp4_y.mat' % alum horn a/b=4 exponential
svdmatname = 'svddata_extfiber.mat' % fiber bonded directly to plate, extended

% load data from mat file
load(svdmatname);

% num time data points
N = length(t); 
%N = 55;  % for testing
%N = 600;

% pull out positions and scale to mm
x = xyz(:,1) * 1e3;
y = xyz(:,2) * 1e3;
z = xyz(:,3) * 1e3;
%x = abs(xyz(:,1)) * 1e3; % reorient negative x vals
%y = xyz(:,1) * 1e3; % flip for y oriented horns
%x = xyz(:,2) * 1e3;


% variables to change for different svd's
if strcmp(svdmatname,'svddata2.mat')
	axval = [-.05 .05 -.03 .03 -.05 .05];
	vwval = [0 20];
	caxval = [0 8]; % color bar magnitude values
	npos = 57;
	runtime = 60;  % num seconds to run movie
	movfname = 'animationdef.avi';  % movie file name
	frate = N/runtime;  % frame rate for movie file
elseif strcmp(svdmatname,'svddata_horn.mat')
	axval = [-.005 .04 0 .02 -.05 .05];
	vwval = [0 20];
	%npos = 13;
	%npos = 1039;
	npos = 500;
	vwval = 3;  % default 3D view
elseif strcmp(svdmatname,'svddata_rect.mat')
	axval = [-.005 .04 0 .02 -.05 .05];
	vwval = [0 20];
	npos = 487;
elseif strcmp(svdmatname,'svddata_extfiber.mat')
	%axval = [-5 5 -15 7 -.05 .05];
	axval = [-15 10 -5 15 -0.3 0.3];
	vwval = [-29.216409612020513,53.633655732220156];
	%vwval = [-37.5 30];
	caxval = [0 15]; % color bar magnitude values
	npos = 4;
	runtime = 30;  % num seconds to run movie
	movfname = 'adhesive_extfiber.avi';  % movie file name
	frate = N/runtime;  % frame rate for movie file
else
	% default properties
	axval = [min(x) max(x) min(y) max(y) -1 1];
	vwval = [-37.5 30];  % default 3D view
	npos = 1039;
	runtime = 60;  % num seconds to run movie
	movfname = 'animationdef.avi';  % movie file name
	frate = N/runtime;  % frame rate for movie file
end

%*****************************************************************************%
% load all workspace vars created from ExportData.m
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
	  %svdmatname         1x16                      32  char                
	  %t                  1x1500                 12000  double              
	  %usd_x              1x1                     4681  struct              
	  %usd_y              1x1                     4681  struct              
	  %usd_z              1x1                     4681  struct              
	  %xyz             1045x3                    25080  double  
%*****************************************************************************%

% retrieve / calculate sample rate
%dt = mean(diff(t));
%Fs = 1 / dt;
% logic pulled from polytec sample CalculateFFT.m
Fs = (usd_x.XCount - 1) / (usd_x.XMax - usd_x.XMin);

% get rows and columns
xpts = unique(x);
ypts = unique(y);
%xpts = unique(round(x)); % need to round _2_x since it's misaligned
%ypts = unique(round(y));
numpts = length(xyz);

% get video image data for plotting as background
xImg = linspace(min(x), max(x), size(imageData, 2));
yImg = linspace(min(y), max(y), size(imageData, 1));

% setup movie
if makemovie == true
	writerObj = VideoWriter(movfname);
	writerObj.FrameRate = frate;
	open(writerObj);
end

% set window size
%set(gcf,'units','normalized','outerposition',[0.25 0.25 0.5 0.5]);
set(gcf,'units','normalized','outerposition',[0.1 0.1 0.8 0.8]);
colormap('jet');

% switch based on view type
if viewtype == 1
	%scatter3(xyz(:,1), xyz(:,2), xyz(:,3),50,'filled');

	% make window full screen
	%set(gcf,'units','normalized','outerposition',[0 0 1 1]);  
	%axis(axval);
	%view([0 20]);  % orient along x-axis tilted down 10 deg

	% plot points as their index number
	%[nrows,ncols] = size(xyz);
	%scatter(xyz(:,1), xyz(:,2), [], 'w');
	%for i = 1:nrows
		%text(xyz(i,1),xyz(i,2),num2str(i))
	%end

	% plot points as their index number
	scatter(x, y, [], 'w');
	hold on; grid on;
	image(xImg, yImg, imageData, 'CDataMapping', 'scaled');
	%image(xImg, yImg, imrotate(imageData,180), 'CDataMapping', 'scaled'); % ab2x
	%image(xImg, yImg, imrotate(flipdim(imageData,1),90), 'CDataMapping', 'scaled'); % ab4y
	%axis([-1 38 0 20]);
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

		%if (yidx == 15)
		if (yidx == 13)
			text(x(ptidx),y(ptidx),sprintf('%d\nc%d',ptidx,xidx),...
				'Color', cmap(xidx,:), 'HorizontalAlignment','center');
		elseif (xidx == 1)
		%elseif (xidx == 39)
			text(x(ptidx),y(ptidx),sprintf('%d\nr%d',ptidx,yidx),...
				'Color', cmap(xidx,:), 'HorizontalAlignment','center');
		else
			text(x(ptidx),y(ptidx),sprintf('%d',ptidx),'Color', cmap(xidx,:), 'HorizontalAlignment','center');
		end
	end

elseif viewtype == 2
	scatter3(x, y, z, 100, 's', 'filled');
	xlabel('x axis');
	ylabel('y axis');
	zlabel('z axis');

	% set axis and view angle per scenario
	axis(axval);
	view(vwval);

elseif viewtype == 3
	% trim the time range if desired
	tmin = 2; tmax = numel(t);
	%tmin = 201;	tmax = 800;

	% create an empty grid at each time step
	%xy = zeros(numel(y),numel(x),numel(t));  % this was too big for matlab

	% plot the x,y,z velocities [mm/s] vs time [micro-sec]
	subplot(3,1,3);
	hold on; grid on;
	plot(t(tmin:tmax)*1e6, amp_x(npos,tmin:tmax)*1e3,'DisplayName','x vel');
	plot(t(tmin:tmax)*1e6, amp_y(npos,tmin:tmax)*1e3,'DisplayName','y vel');
	plot(t(tmin:tmax)*1e6, amp_z(npos,tmin:tmax)*1e3,'DisplayName','z vel');
	phx = line([0,0],get(gca,'ylim'),'color','red');
	xlabel('time [\mus]');
	ylabel('x velocity [mm/s]');
	legend;

	% calculate overall velocity values, convert to mm/s
	velx = amp_x * 1e3;
	vely = amp_y * 1e3;
	velz = amp_z * 1e3;
	vel = sqrt(velx.^2 + vely.^2 + velz.^2);
	%vel = abs(amp_x) * 1e3;  % absolute value of x vel
	%vel = amp_x * 1e3;  % mimic X_acoustic_horn.avi, shows negative values

	% animation loop
	for tidx = tmin:tmax
		% increment the position based on calculating displacement
		% from the velocity values and the time step
		% velocity values are in amp_[x,y,z] in m/s
		% time value is in t in s
		% displacement is magnified so we can see movement (polytec does this too)
		dt = t(tidx) - t(tidx-1);
		xi = x + (velx(:,tidx) * dt) * 1e5;
		yi = y + (vely(:,tidx) * dt) * 1e5;
		zi = z + (velz(:,tidx) * dt) * 1e5;

		% contour plot stuff
		% get data into a grid
		%xy = zeros(numel(ypts),numel(xpts));

		%for xidx = 1:numel(xpts)
			%for yidx = 1:numel(ypts)
				%ptidx = find(x == xpts(xidx) & y == ypts(yidx));
				%if ~isempty(ptidx)
					%xy(yidx,xidx) = vel(ptidx,tidx);
				%end
			%end
		%end
		
		% plot the 3D scatter	
		subplot(3,1,[1:2]);
		hold on; grid on;
		%image(xImg, yImg, imageData, 'CDataMapping', 'scaled');
		scatter3(xi, yi, zi, 100, vel(:,tidx), 's', 'filled');
		plot3(xi(npos), yi(npos), zi(npos), 'or', 'MarkerSize', 20, 'LineWidth', 5);  % highlight a point
		caxis(caxval);
		%caxis([-8 8]);
		%title('velocity over time');
		%xlabel('x point num');
		%ylabel('y point num');
		colorbar;
		
		%contourf(xy);
		
		% set axis and view angle per scenario
		axis(axval);
		view(vwval);
		%view([0 20]);  % orient along x-axis tilted down 10 deg

		% update the vertical lines on the velocity plots
		tt = t(tidx)*1e6;  % new time / x value
		set(phx,'XData',[tt,tt]);

		tidx
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end

	end  % end time loop

elseif viewtype == 4
	a = (round(xyz(:,2),4) == .0099);
	b = (round(xyz(:,2),4) == .0191);
	%b = (round(xyz(:,2),4) == .0163);
	%c = (round(xyz(:,2),4) == .0036);
	c = (round(xyz(:,2),4) == .0008);

	vel = amp_x * 1e3; % convert to mm/s

	%for i = 1:N
	for i = 201:800
		plot(xyz(a,1),vel(a,i),'LineWidth',2)
		hold on
		plot(xyz(b,1),vel(b,i),'LineWidth',2)
		plot(xyz(c,1),vel(c,i),'LineWidth',2)
		grid on
		axis([-.005 .04 -50 50]);
		title('x velocity versus x position for every rows .0099/.0191/.008 over time indexes 201 - 800');
		xlabel('x position [mm]');
		ylabel('x velocity [mm/s]');
		hold off

		i
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end

	end

elseif viewtype == 5
	% group points by x value
	[C,ia,idx] = unique(xyz(:,1));

	%for i = 1:N
	for i = 201:800
		% avg vel per x value
		vel = accumarray(idx,amp_x(:,i),[],@mean);
		vel = vel * 1e3;
		plot(1:numel(vel),vel,'LineWidth',2)
		grid on
		axis([1 57 -10 10]);
		title('avg x velocity versus x position by column over time indexes 201 - 800');
		xlabel('x position [mm]');
		ylabel('avg x velocity [mm/s]');

		i
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end

	end

elseif viewtype == 6
	% points to look at
	%npos = [100 200 500 800];
	%npos = [13 27 100 264 500 648 739 1003];
	%npos = [27 264 726 1039];
	npos = [13 256 472 711 846 1039];

	% calculate sampling frequency
	%dt = mean(diff(t));
	%Fs = 1 / dt;
	% logic pulled from polytec sample CalculateFFT.m
	Fs = (usd_x.XCount - 1) / (usd_x.XMax - usd_x.XMin);

	scatter(xyz(:,1), xyz(:,2), 75, 'b', 'filled');
	hold on;
	plot(xyz(npos,1), xyz(npos,2), 'ro', 'MarkerSize', 20);  % highlight a point
	%figure;
	for i = 1:numel(npos)
		figure;
		pwelch(amp_x(npos(i),:),[],[],[],Fs);
		title(sprintf('Welch Power Spectral Density Estimate: Point %d',npos(i)));
		%hold on;
	end

elseif viewtype == 7
	% load rectangle data for comparison
	amp_x1 = amp_x;
	xyz1 = xyz;
	load('svddata_rect.mat');
	N = 1000;  % num time steps

	% group points by x value
	[C,ia,idx] = unique(xyz(:,1));
	[C1,ia1,idx1] = unique(xyz1(:,1));

	% get all positions at a specific y val (so gets a horiz line / row)
	a = (round(xyz(:,2),4) == .0098);
	a1 = (round(xyz1(:,2),4) == .0099);

	vela = amp_x(a,:) * 1e3; % convert to mm/s
	vela1 = amp_x1(a1,:) * 1e3; % convert to mm/s

	for i = 1:N
		% avg vel per x value
		vel = accumarray(idx,amp_x(:,i),[],@mean);
		vel1 = accumarray(idx1,amp_x1(:,i),[],@mean);
		vel = vel * 1e3;
		vel1 = vel1 * 1e3;
		
		subplot(4,1,1);
		plot(1:numel(vel),vel,'LineWidth',2)
		title('rectangle: avg x vel by col');
		grid on
		axis([1 57 -10 10]);
		
		subplot(4,1,2);
		plot(1:numel(vel1),vel1,'LineWidth',2)
		title('horn: avg x vel by col');
		grid on
		axis([1 57 -10 10]);

		subplot(4,1,3);
		plot(1:numel(vela(:,1)),vela(:,i),'LineWidth',2)
		title('rectangle: x vel for row y=.0098');
		grid on
		axis([1 57 -10 10]);
		%axis([-.005 .04 -50 50]);

		subplot(4,1,4);
		plot(1:numel(vela1(:,1)),vela1(:,i),'LineWidth',2)
		title('horn: x vel for row y=.0099');
		grid on
		axis([1 57 -10 10]);
		%axis([1 57 -50 50]);
		%axis([-.005 .04 -50 50]);

		i
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end
	end
elseif viewtype == 8
	velmax = max(abs(amp_x) * 1e3,[],2);
	hold on; grid on;
	image(xImg, yImg, imageData, 'CDataMapping', 'scaled');
	scatter(x,y,50,velmax,'filled');
	title('max x vel (mm/s) over all times');
	ylabel('y position [mm]');
	xlabel('x position [mm]');
	axis([-1 38 0 20]);
	caxis([0 10]);

elseif viewtype == 9
	% preallocate array to hold time values for a single data point
	sigx = zeros(1,N);

	% preallocate array to hold 300 kHz magnitude values for each pt/time
	sigxt = zeros(numpts,N);

	for ptidx = 1:numpts
		% pull out data for the single data point
		sigx = amp_x(ptidx,:);

		% get the wavelet transform data
		[wt,f] = cwt(sigx,Fs);
		%[wt,f] = cwt(sigx,'bump',Fs);

		% pull out the index for our 300 kHz signal
		%idx300 = max(find((round(f) > 290e3 & round(f) < 310e3)));
		[~,idx300] = min(abs(f - 300e3)); 

		% retrieve cwt calculated magnitude of 300 kHz signal at each time step
		% and load into new array
		sigxt(ptidx,:) = abs(wt(idx300,:));
		%sigxt(ptidx,:) = abs(wt(idx300,:)).^2;
		%sigxt(ptidx,:) = (abs(wt(idx300,:)).^2 >= 0.5e-3);
		
		%sigxt(ptidx,:) = abs(wt(idx300,:));
		%mag = abs(wt(idx300,:)).^2;
		%maxmag = max(mag);
		%sigxt(ptidx,:) = (mag == maxmag);

		ptidx
		%plot(t,sigxt(ptidx,:));
		%hold on;
		%drawnow
	end

	% plot the magnitude value for chosen point
	subplot(3,1,3);
	hold on;
	grid on;
	plot(t*1e6, sigxt(npos,:));
	phx = line([0,0],get(gca,'ylim'),'color','red');
	xlabel('time [\mus]');
	ylabel('magnitude [?]');

	for tidx = 1:N
		% plot points with color by 300 kHz magnitude
		subplot(3,1,[1:2]); hold on;
		image(xImg, yImg, imageData, 'CDataMapping', 'scaled');
		scatter(x, y, 300, sigxt(:,tidx), 's', 'filled');
		%xlabel('x position [mm]');
		%ylabel('y position [mm]');
		title('Magnitude of 300 kHz over time, default cwt');
		xlabel('x point num');
		ylabel('y point num');
		caxis([0 2.5e-3]);  % sets the range of values for the colorbar
		%caxis([0 1]);  % sets the range of values for the colorbar
		colorbar;
		plot(x(npos), y(npos), 'or', 'MarkerSize', 20, 'LineWidth',5);  % highlight a point
		
		% update red line on single point plot
		tt = t(tidx)*1e6;  % new time / x value
		set(phx,'XData',[tt,tt]);
		
		tidx	
		drawnow
		
		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end
	end

elseif viewtype == 10
	% ypts are rows, 1 - 27 for horn: 13 is center line
	ptsidx = find(xyz(:,2)*1e3 == ypts(13));
	d = amp_x(ptsidx,:);
	for idx = 1:numel(ptsidx)
		% use this to show cwt plots
		%cwt(d(idx,:),Fs,'FrequencyLimits',[200e3 500e3]);
	
		% use this to show contourf plots	
		[cfs,f] = cwt(d(idx,:),Fs,'FrequencyLimits',[200e3 500e3]);
		contourf(t*1e6,f*1e-3,abs(cfs)); 
		axis tight;
		grid on;
		xlabel('Time [\mus]');
		ylabel('Approximate Frequency (kHz)');
		title('CWT with Frequency vs Time');
		caxis([0 10e-3]);
		colorbar;

		idx
		drawnow
		
		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end
	end


elseif viewtype == 11
	% trim the time range
	tmin = 201;
	tmax = 800;

	% convert x velocity values to mm/s	
	vel = amp_x * 1e3;

	% initialize vel max
	velmax = zeros(numel(ypts), N);

	% get colormap for making all lines different colors
	cmap = jet(numel(ypts));

	% loop all time steps
	%for tidx = 1:N
	for tidx = tmin:tmax
		for yidx = 1:2:numel(ypts)
			% get indexes of all points in current row
			ptsidx = find(y == ypts(yidx));

			% plot the x velocity value versus x position value
			subplot(3,1,[1:2]);
			plot(x(ptsidx),vel(ptsidx,tidx), 'Color',cmap(yidx,:),'DisplayName',['row ' num2str(yidx)]);
			hold on; grid on;

			if yidx == 1
				title('x velocity versus x position for every other row over time indexes 201 - 800');
				xlabel('x position [mm]');
				ylabel('x velocity [mm/s]');
				axis([-1 45 -75 75]);
			end

			% calculate max x vel in each row at this time step
			velmax(yidx,tidx) = max(abs(vel(ptsidx,tidx)));
			
			% plot max vel values
			subplot(3,1,3);
			plot(t(tmin:tidx)*1e6, velmax(yidx,tmin:tidx), '-', 'Color', cmap(yidx,:));
			hold on; grid on;

			if yidx == 1
				xlim([t(tmin)*1e6 t(tmax)*1e6]);
				ylim([0 150]);
				title('absolute value of x velocity for each row at each time step');
				xlabel('time [\mus]');
				ylabel('abs x velocity [mm/s]');
			end
		end

		subplot(3,1,[1:2]);
		set(gca,'Color', [0.7,0.7,0.7]);
		legend show;
		hold off;

		subplot(3,1,3);
		set(gca,'Color', [0.7,0.7,0.7]);
		hold off;

		tidx
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end

	end

elseif viewtype == 12
	% trim the time range
	tmin = 201;
	tmax = 800;

	% preallocate array to hold time values for a single data point
	sigx = zeros(1,N);

	% preallocate array to hold 300 kHz magnitude values for each pt/time
	sigxt = zeros(numpts,N);

	for ptidx = 1:numpts
		% pull out data for the single data point
		sigx = amp_x(ptidx,:);

		% get the wavelet transform data
		[wt,f] = cwt(sigx,Fs);
		%[wt,f] = cwt(sigx,'bump',Fs);

		% pull out the index for our 300 kHz signal
		%idx300 = max(find((round(f) > 290e3 & round(f) < 310e3)));
		[~,idx300] = min(abs(f - 300e3)); 

		% retrieve cwt calculated magnitude of 300 kHz signal at each time step
		% and load into new array
		sigxt(ptidx,tmin:tmax) = abs(wt(idx300,tmin:tmax));
		%sigxt(ptidx,:) = abs(wt(idx300,:)).^2;
		%sigxt(ptidx,:) = (abs(wt(idx300,:)).^2 >= 0.5e-3);
		
		%sigxt(ptidx,:) = abs(wt(idx300,:));
		%mag = abs(wt(idx300,:)).^2;
		%maxmag = max(mag);
		%sigxt(ptidx,:) = (mag == maxmag);

		ptidx
		%plot(t,sigxt(ptidx,:));
		%hold on;
		%drawnow
	end

	% initialize sigx max
	sigxmax = zeros(numel(ypts), N);

	% get colormap for making all lines different colors
	cmap = jet(numel(ypts));

	% loop all time steps
	%for tidx = 1:N
	for tidx = tmin:tmax
		%for yidx = 1:2:numel(ypts)
		for yidx = 9:1:18
			% get indexes of all points in current rwo
			ptsidx = find(y == ypts(yidx));

			% plot the x velocity value versus x position value
			subplot(3,1,[1:2]);
			plot(x(ptsidx),sigxt(ptsidx,tidx), 'Color',cmap(yidx,:),'DisplayName',['row ' num2str(yidx)]);
			hold on; grid on;

			if yidx == 9
				title('300 kHz magnitude versus x position for every other row over time indexes 201 - 800');
				xlabel('x position [mm]');
				ylabel('magnitude');
				axis([-1 45 0 0.1]);
			end

			% calculate max magnitude in each row at this time step
			sigxmax(yidx,tidx) = max(abs(sigxt(ptsidx,tidx)));
			
			% plot max magnitude values
			subplot(3,1,3);
			plot(t(tmin:tidx)*1e6, sigxmax(yidx,tmin:tidx), '-', 'Color', cmap(yidx,:));
			hold on; grid on;

			if yidx == 9
				xlim([t(tmin)*1e6 t(tmax)*1e6]);
				ylim([0 0.1]);
				title('300 kHz magnitude for each row at each time step');
				xlabel('time [\mus]');
				ylabel('magnitude');
			end
		end

		subplot(3,1,[1:2]);
		set(gca,'Color', [0.7,0.7,0.7]);
		legend show;
		hold off;

		subplot(3,1,3);
		set(gca,'Color', [0.7,0.7,0.7]);
		hold off;

		tidx
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end

	end


elseif viewtype == 13
	% trim the time range
	tmin = 201;
	tmax = 800;

	% convert x velocity values to mm/s	
	vel = amp_x * 1e3;

	% initialize vel max
	velmax = zeros(numel(ypts), N);

	% get colormap for making all lines different colors
	cmap = jet(numel(xpts));

	% loop all time steps
	%for tidx = 1:N
	for tidx = tmin:tmax
		for xidx = 1:3:numel(xpts)
			% get indexes of all points in current column
			ptsidx = find(x == xpts(xidx));

			% plot the x velocity value versus y position value
			subplot(3,1,[1:2]);
			plot(y(ptsidx),vel(ptsidx,tidx), 'Color',cmap(xidx,:),'DisplayName',['column ' num2str(xidx)]);
			hold on; grid on;

			if xidx == 1
				title('x velocity versus y position for every third column over time indexes 201 - 800');
				xlabel('y position [mm]');
				ylabel('x velocity [mm/s]');
				axis([0 22 -75 75]);
			end

			% calculate max x vel in each column at this time step
			velmax(xidx,tidx) = max(abs(vel(ptsidx,tidx)));
			
			% plot max vel values
			subplot(3,1,3);
			plot(t(tmin:tidx)*1e6, velmax(xidx,tmin:tidx), '-', 'Color', cmap(xidx,:));
			hold on; grid on;

			if xidx == 1
				xlim([t(tmin)*1e6 t(tmax)*1e6]);
				ylim([0 100]);
				title('absolute value of max x velocity for each column at each time step');
				xlabel('time [\mus]');
				ylabel('abs max x velocity [mm/s]');
			end
		end

		subplot(3,1,[1:2]);
		set(gca,'Color', [0.7,0.7,0.7]);
		legend show;
		hold off;

		subplot(3,1,3);
		set(gca,'Color', [0.7,0.7,0.7]);
		hold off;

		tidx
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end

	end

elseif viewtype == 14
	% trim the time range
	tmin = 201;
	tmax = 800;

	% preallocate array to hold time values for a single data point
	sigx = zeros(1,N);

	% preallocate array to hold 300 kHz magnitude values for each pt/time
	sigxt = zeros(numpts,N);

	for ptidx = 1:numpts
		% pull out data for the single data point
		sigx = amp_x(ptidx,:);

		% get the wavelet transform data
		[wt,f] = cwt(sigx,Fs);
		%[wt,f] = cwt(sigx,'bump',Fs);

		% pull out the index for our 300 kHz signal
		[~,idx300] = min(abs(f - 300e3)); 

		% retrieve cwt calculated magnitude of 300 kHz signal at each time step
		% and load into new array
		sigxt(ptidx,tmin:tmax) = abs(wt(idx300,tmin:tmax));

	%allxt(ptidx,:) = abs(wt(:,:));
		
		ptidx
	end

	% initialize sigx max
	sigxmax = zeros(numel(xpts), N);

	% get colormap for making all lines different colors
	cmap = jet(numel(xpts));

	% loop all time steps
	%for tidx = 1:N
	for tidx = tmin:tmax
		for xidx = 1:3:numel(xpts)
			% get indexes of all points in current column
			ptsidx = find(x == xpts(xidx));

			% plot the x velocity value versus y position value
			subplot(3,1,[1:2]);
			plot(y(ptsidx),sigxt(ptsidx,tidx), 'Color',cmap(xidx,:),'DisplayName',['column ' num2str(xidx)]);
			hold on; grid on;

			if xidx == 1
				title('300 kHz magnitude versus y position for every third column over time indexes 201 - 800');
				xlabel('y position [mm]');
				ylabel('magnitude');
				%axis([0 22 0 0.1]);
				axis([0 22 0 0.1]);
			end

			% calculate max magnitude in each column at this time step
			%sigxmax(xidx,tidx) = max(abs(sigxt(ptsidx,tidx)));
			sigxmax(xidx,tidx) = mean(sigxt(ptsidx,tidx));
			
			% plot max magnitude values
			subplot(3,1,3);
			plot(t(tmin:tidx)*1e6, sigxmax(xidx,tmin:tidx), '-', 'Color', cmap(xidx,:));
			hold on; grid on;

			if xidx == 1
				xlim([t(tmin)*1e6 t(tmax)*1e6]);
				ylim([0 0.02]);
				title('300 kHz max magnitude for each column at each time step');
				xlabel('time [\mus]');
				ylabel('max magnitude');
			end
		end

		subplot(3,1,[1:2]);
		set(gca,'Color', [0.7,0.7,0.7]);
		legend show;
		hold off;

		subplot(3,1,3);
		set(gca,'Color', [0.7,0.7,0.7]);
		hold off;

		tidx
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end

	end


elseif viewtype == 15
	% 1 = column plots of mangnitude for all points in column
	% 2 = heat map with each point showing sum of magnitudes over full time range
	plottype = 1

	% trim the time range
	%tmin = 201;
	%tmax = 800;
	tmin = 1;
	tmax = numel(t);

	% preallocate array to hold time values for a single data point
	sigx = zeros(1,N);

	% preallocate array to hold 300 kHz magnitude values for each pt/time
	sigxt = zeros(numpts,N);
	sigxtpks = zeros(numpts,N);
	sigxtsum = zeros(1,numpts);

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
		sigxtsum(ptidx) = sum(abs(wt(idx300,tmin:tmax)));

		ptidx
	end

	% get colormap for making all lines different colors
	cmap = jet(numel(ypts));

	if plottype == 2

		scatter(x, y, 300, sigxtsum, 's', 'filled');
		title(sprintf('300 kHz magnitude sum for each point over time range %d to %d',tmin,tmax));
		xlabel('x position [mm]');
		ylabel('y position [mm]');
		colorbar;

	elseif plottype == 1

		% loop columns
		for xidx = 1:numel(xpts)
		%for xidx = [1 29 50]
			figure;
			hold on; grid on;

			% get indexes of all points in current column
			ptsidx = find(x == xpts(xidx));

			% plot time-frequency for each point in this column
			for ptidx = ptsidx(1):ptsidx(end)
				% get row of this point so we can keep row colors consistent
				yidx = find(ypts == y(ptidx));

				% plot
				plot(t*1e6, sigxt(ptidx,:), 'Color', cmap(yidx,:), 'DisplayName', ['pt ' num2str(ptidx)],...
					'LineWidth',2);
			end

			title(sprintf('300 kHz magnitude, bump cwt, column %d, all points',xidx));
			xlabel('time [\mus]');
			ylabel('magnitude');
			set(gca,'Color', [0.7,0.7,0.7]);
			legend show;
			hold off;

			if makemovie == true
				writeVideo(writerObj,getframe(gcf));
			end
		end

	end % plottype

elseif viewtype == 16
	% trim the time range
	tmin = 201;
	tmax = 800;
	%tmin = 1;
	%tmax = numel(t);

	% preallocate array to hold time values for a single data point
	sigx = zeros(1,N);

	% preallocate array to hold 300 kHz magnitude values for each pt/time
	sigxt = zeros(numpts,N);
	sigxtpks = zeros(numpts,N);

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

		ptidx
	end

	% plot the magnitude value for chosen point
	subplot(3,1,3);
	hold on; grid on;
	%plot(t*1e6, sigxt(npos,:));
	%plot(t, sigxt(npos,:));
	findpeaks(sigxt(npos,:));
	phx = line([0,0],get(gca,'ylim'),'color','red');
	xlabel('time [\mus]');
	ylabel('magnitude');

	for tidx = tmin:tmax
		% plot points with color by 300 kHz magnitude
		subplot(3,1,[1:2]); hold on;
		%image(xImg, yImg, imageData, 'CDataMapping', 'scaled');
		scatter(x, y, 300, sigxtpks(:,tidx), 's', 'filled');
		%xlabel('x position [mm]');
		%ylabel('y position [mm]');
		title('Magnitude of 300 kHz peak over time, bump cwt');
		xlabel('x point num');
		ylabel('y point num');
		caxis([0 0.02]);  % sets the range of values for the colorbar
		%caxis([0 1]);  % sets the range of values for the colorbar
		colorbar;
		plot(x(npos), y(npos), 'or', 'MarkerSize', 20, 'LineWidth',5);  % highlight a point
		
		% update red line on single point plot
		%tt = t(tidx)*1e6;  % new time / x value
		%set(phx,'XData',[tt,tt]);
		set(phx,'XData',[tidx,tidx]);
		
		tidx	
		drawnow
		
		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end
	end


colorbar;
end

if makemovie == true
	%movie(M);
	close(writerObj);
end  % end makemovie

