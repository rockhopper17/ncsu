% clear all vars and plots
close all; clear all; clc;

%*****************************************************************************%
% variables that can be changed

% different views
% 1 = 3D scatter static view of positions to confirm general shape (can show idx nums)
% 2 = 3D scatter with animation
% 3 = 3D scatter with animation and x,y 2D vel plots
% 4 = points in a line at certain y values (.0099 middle line plus others)
% 5 = avg x vel by x pos
% 6 = pwelch power spectral density estimates
% 7 = avg x vel, center x vel by x pos comparison horn to rect (4 subplots)
% 8 = 2D plot of max x vel at each point
viewtype = 6

% **************************
% load all workspace vars created from ExportData.m
% variables in mat file, note that sizes are particular to test load
%    but variables will have same names
	%>> whos
	  %Name              Size                 Bytes  Class     Attributes

	  %amp_x           505x2500            10100000  double              
	  %amp_y           505x2500            10100000  double              
	  %amp_z           505x2500            10100000  double              
	  %fnames            1x2                    252  string              
	  %numf              1x1                      8  double              
	  %svdmatname        1x12                    24  char                
	  %t                 1x2500               20000  double              
	  %usd_x             1x1                   4681  struct              
	  %usd_y             1x1                   4681  struct              
	  %usd_z             1x1                   4681  struct              
	  %xyz             505x3                  12120  double

% orig x_8cm test data (scan_time.svd)
%load('svddata.mat');

% orig x_8cm test data with plate data included (+scan_time_plate.svd)
%load('svddata2.mat');
%axval = [-.05 .05 -.003 .003 -.05 .05];
%vwval = [0 20];
%npos = 57;

% horn test data
load('svddata_horn.mat');
axval = [-.005 .04 0 .02 -.05 .05];
vwval = [0 20];
npos = 500;
%vwval = 3;  % default 3D view

% rectangle test data
%load('svddata_rect.mat');
%axval = [-.005 .04 0 .02 -.05 .05];
%vwval = [0 20];
%npos = 487;
% **************************

makemovie = false;  % flag for making a movie (can be slow) or not
runtime = 90;  % num seconds to run movie
movfname = 'procsvdmovie_v4.avi';  % movie file name

colormap('jet');
%*****************************************************************************%

if viewtype == 7
	amp_x1 = amp_x;
	xyz1 = xyz;
	load('svddata_rect.mat');
	N = 1000;  % num time steps
else
	N = length(t); 
end

% num scan points
numpts = length(xyz);
%N = 50;  % for testing

% setup movie
if makemovie == true
	writerObj = VideoWriter(movfname);
	frate = N/runtime;  % frame rate for movie file
	writerObj.FrameRate = frate;
	open(writerObj);
end  % end makemovie

% switch based on view type
if viewtype == 1
	scatter3(xyz(:,1), xyz(:,2), xyz(:,3),50,'filled');

	% make window full screen
	%set(gcf,'units','normalized','outerposition',[0 0 1 1]);  
	%axis(axval);
	%view([0 20]);  % orient along x-axis tilted down 10 deg

	% plot points as their index number
	[nrows,ncols] = size(xyz);
	scatter(xyz(:,1), xyz(:,2), [], 'w');
	for i = 1:nrows
		text(xyz(i,1),xyz(i,2),num2str(i))
	end

elseif viewtype == 2
	% make window full screen
	set(gcf,'units','normalized','outerposition',[0 0 1 1]);  

	% plot first position
	scatter3(xyz(:,1), xyz(:,2), xyz(:,3),50,'filled');

	% calculate overall velocity values, conver to mm/s
	%vel = sqrt(amp_x(:,:).^2 + amp_y(:,:).^2 + amp_z(:,:).^2) * 1e3;
	vel = amp_x * 1e3;

	% animation loop
	for i = 2:N
		% increment the position based on calculating displacement
		% from the velocity values and the time step
		% velocity values are in amp_[x,y,z] in m/s
		% time value is in t in s
		% displacement is magnified so we can see movement (polytec does this too)
		x = xyz(:,1) + (amp_x(:,i) * (t(i) - t(i-1))) * 1e6; 
		%y = xyz(:,2) + (amp_y(:,i) * (t(i) - t(i-1))) * 1e6;
		%z = xyz(:,3) + (amp_z(:,i) * (t(i) - t(i-1))) * 1e6;
		y = xyz(:,2);
		z = xyz(:,3);
		
		% plot the 3D scatter	
		%hold on;
		scatter3(x, y, z, 50, vel(:,i), 'filled');  % main 3D scatter plot
		%plot3(x(npos), y(npos), z(npos), 'or', 'MarkerSize', 20);  % highlight a point
		caxis([0 5]);  % sets the range of values for the colorbar
		grid on;
		colorbar;  % show the colorbar on plot
		
		% set axis and view angle per scenario
		axis(axval);
		%hold off;
		%view([0 20]);  % orient along x-axis tilted down 10 deg

		i  % print index value so we can follow progress in the command window
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end

	end  % end time loop

elseif viewtype == 3
	% make window full screen
	set(gcf,'units','normalized','outerposition',[0 0 1 1]);  

	% plot the x,y,z velocities [mm/s] vs time [micro-sec]
	%subplot(3,2,2);
	%subplot(4,1,3);
	subplot(4,1,4);
	hold on;
	grid on;
	plot(t*1e6, amp_x(npos,:)*1e3);
	phx = line([0,0],get(gca,'ylim'),'color','red');
	xlabel('time [\mus]');
	ylabel('x velocity [mm/s]');

	%subplot(3,2,4);
	%subplot(4,1,4);
	%hold on;
	%grid on;
	%plot(t*1e6, amp_y(npos,:)*1e3);
	%phy = line([0,0],get(gca,'ylim'),'color','red');
	%xlabel('time [\mus]');
	%ylabel('y velocity [mm/s]');

	%subplot(3,2,6);
	%subplot(4,1,4);
	%hold on;
	%grid on;
	%plot(t*1e6, amp_z(npos,:)*1e3);
	%phz = line([0,0],get(gca,'ylim'),'color','red');
	%xlabel('time [\mus]');
	%ylabel('z velocity [mm/s]');
	
	% calculate overall velocity values, conver to mm/s
	%vel = sqrt(amp_x(:,:).^2 + amp_y(:,:).^2 + amp_z(:,:).^2) * 1e3;
	vel = abs(amp_x) * 1e3;

	% animation loop
	for i = 2:N
		% increment the position based on calculating displacement
		% from the velocity values and the time step
		% velocity values are in amp_[x,y,z] in m/s
		% time value is in t in s
		% displacement is magnified so we can see movement (polytec does this too)
		x = xyz(:,1) + (amp_x(:,i) * (t(i) - t(i-1))) * 1e5;
		%y = xyz(:,2) + (amp_y(:,i) * (t(i) - t(i-1))) * 1e6;
		%z = xyz(:,3) + (amp_z(:,i) * (t(i) - t(i-1))) * 1e6;
		y = xyz(:,2);
		z = xyz(:,3);
		
		% plot the 3D scatter	
		%subplot(4,1,[1,2]);
		subplot(4,1,[1:3]);
		hold on;
		scatter3(x, y, z, 50, vel(:,i), 'filled');  % main 3D scatter plot
		plot3(x(npos), y(npos), z(npos), 'or', 'MarkerSize', 20);  % highlight a point
		caxis([0 5]);  % sets the range of values for the colorbar
		grid on;
		colorbar;  % show the colorbar on plot
		
		% set axis and view angle per scenario
		axis(axval);
		view(vwval);
		%view([0 20]);  % orient along x-axis tilted down 10 deg

		% update the vertical lines on the velocity plots
		tt = t(i)*1e6;  % new time / x value
		set(phx,'XData',[tt,tt]);
		%set(phy,'XData',[tt,tt]);
		%set(phz,'XData',[tt,tt]);

		i  % print index value so we can follow progress in the command window
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

	for i = 1:N
		plot(xyz(a,1),vel(a,i),'LineWidth',2)
		hold on
		plot(xyz(b,1),vel(b,i)+25,'LineWidth',2)
		plot(xyz(c,1),vel(c,i)-25,'LineWidth',2)
		grid on
		axis([-.005 .04 -50 50]);
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

	for i = 1:N
		% avg vel per x value
		vel = accumarray(idx,amp_x(:,i),[],@mean);
		vel = vel * 1e3;
		plot(1:numel(vel),vel,'LineWidth',2)
		grid on
		axis([1 57 -10 10]);

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
	npos = [27 264 726 1039];

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
	% make window full screen
	%set(gcf,'units','normalized','outerposition',[0 0 1 1]);  
	set(gcf, 'Position',  [100, 100, 800, 600]);

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
	scatter(xyz(:,1),xyz(:,2),50,velmax,'filled');
	caxis([0 10]);
	colorbar;
end

if makemovie == true
	%movie(M);
	close(writerObj);
end  % end makemovie

