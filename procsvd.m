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
viewtype = 1

npos = 57;  % highlighted position, used for x and y vel plots

% svd data file names (matlab workspace variables exported from windows machine)
%dfname = 'svddata.mat';  % orig x_8cm test data (scan_time.svd)
dfname = 'svddata2.mat';  % orig x_8cm test data with plate data included (+scan_time_plate.svd)
%dfname = 'svddata_horn.mat';  % horn test data (scan_time_horn.svd)
%dfname = 'svddata_rect.mat';  % rectangle test data (scan_time_rect.svd)

makemovie = false;  % flag for making a movie (can be slow) or not
runtime = 90;  % num seconds to run movie
movfname = 'procsvdmovie_horn.avi';  % movie file name

colormap('jet');
%*****************************************************************************%

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
load(dfname);

% number of time steps and scan points
N = length(t); 
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

	% plot points as their index number
	%[nrows,ncols] = size(xyz);
	%scatter(xyz(:,1), xyz(:,2), [], 'w');
	%for i = 1:nrows
		%text(xyz(i,1),xyz(i,2),num2str(i))
	%end

elseif viewtype == 2
	% plot first position
	scatter3(xyz(:,1), xyz(:,2), xyz(:,3),50,'filled');

	%vel = zeros(N,numpts);
	%for i = 1:N
		%for j = 1:numpts
			%vel(i,j) = sqrt(amp_x(j,i)^2 + amp_y(j,i)^2 + amp_z(j,i)^2) * 1e3; % convert to mm/s
		%end
	%end
	vel = sqrt(amp_x(:,:).^2 + amp_y(:,:).^2 + amp_z(:,:).^2) * 1e3; % convert to mm/s
	%vel = amp_x(:,:) * 1e3; % convert to mm/s

	% animation loop
	for i = 2:N
		% increment the position based on calculating displacement
		% from the velocity values and the time step
		% velocity values are in amp_[x,y,z] in m/s
		% time value is in t in s
		% displacement is magnified so we can see movement (polytec does this too)
		%x = xyz(:,1) + (amp_x(:,i) * (t(i) - t(i-1))) * 1e6; 
		%y = xyz(:,2) + (amp_y(:,i) * (t(i) - t(i-1))) * 1e6;
		%z = xyz(:,3) + (amp_z(:,i) * (t(i) - t(i-1))) * 1e6;
		
		%pos(:,1) = pos(:,1) + (amp_x(:,i) * (t(i+1) - t(i))) * 1e5;  % trying out magnification
		%pos(:,2) = pos(:,2) + (amp_y(:,i) * (t(i+1) - t(i))) * 1e5;  % so we can see someething
		%pos(:,3) = pos(:,3) + (amp_z(:,i) * (t(i+1) - t(i))) * 1e5;  % move (the * 1e5 )

		% calculate the total velocity magnitude
		%vel = sqrt(amp_x(:,i).^2 + amp_y(:,i).^2 + amp_z(:,i).^2) * 1e3; % convert to mm/s

		% plot the 3D scatter	
		%scatter3(x, y, z, 50, vel, 'filled');  % main 3D scatter plot
		scatter3(xyz(:,1), xyz(:,2), xyz(:,3), 50, vel(:,i), 'filled');  % main 3D scatter plot
		%plot3(x(npos), y(npos), z(npos), 'o', 'MarkerSize', 20);  % highlight a point
		%axis([-.05 .05 -.005 .005 -.1 .1]);
		%axis([-.01 .05 -.005 .05 -.1 .1]);
		caxis([0 10]);  % sets the range of values for the colorbar
		colorbar;  % show the colorbar on plot
		
		i  % print index value so we can follow progress in the command window
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end  % end makemmovie

	end  % end time loop


elseif viewtype == 3
	% make window full screen
	set(gcf,'units','normalized','outerposition',[0 0 1 1]);  

	% plot the x,y,z velocities [mm/s] vs time [micro-sec]
	%subplot(3,2,2);
	subplot(4,1,3);
	hold on;
	grid on;
	plot(t*1e6, amp_x(npos,:)*1e3);
	phx = line([0,0],get(gca,'ylim'),'color','red');
	xlabel('time [\mus]');
	ylabel('x velocity [mm/s]');

	%subplot(3,2,4);
	subplot(4,1,4);
	hold on;
	grid on;
	plot(t*1e6, amp_y(npos,:)*1e3);
	phy = line([0,0],get(gca,'ylim'),'color','red');
	xlabel('time [\mus]');
	ylabel('y velocity [mm/s]');

	%subplot(3,2,6);
	%subplot(4,1,4);
	%hold on;
	%grid on;
	%plot(t*1e6, amp_z(npos,:)*1e3);
	%phz = line([0,0],get(gca,'ylim'),'color','red');
	%xlabel('time [\mus]');
	%ylabel('z velocity [mm/s]');
	
	% animation loop
	for i = 2:N
		% increment the position based on calculating displacement
		% from the velocity values and the time step
		% velocity values are in amp_[x,y,z] in m/s
		% time value is in t in s
		% displacement is magnified so we can see movement (polytec does this too)
		x = xyz(:,1) + (amp_x(:,i) * (t(i) - t(i-1))) * 1e6; 
		y = xyz(:,2) + (amp_y(:,i) * (t(i) - t(i-1))) * 1e6;
		z = xyz(:,3) + (amp_z(:,i) * (t(i) - t(i-1))) * 1e6;
		
		% calculate the total velocity magnitude
		vel = sqrt(amp_x(:,i).^2 + amp_y(:,i).^2 + amp_z(:,i).^2) * 1e3; % convert to mm/s

		% plot the 3D scatter	
		subplot(4,1,[1,2]);
		hold on;
		scatter3(x, y, z, 50, vel, 'filled');  % main 3D scatter plot
		plot3(x(npos), y(npos), z(npos), 'o', 'MarkerSize', 20);  % highlight a point
		axis([-.05 .05 -.005 .005 -.1 .1]);
		caxis([0 5]);  % sets the range of values for the colorbar
		grid on;
		view([0 -10]);  % orient along x-axis tilted down 10 deg
		colorbar;  % show the colorbar on plot

		% update the vertical lines on the velocity plots
		tt = t(i)*1e6;  % new time / x value
		set(phx,'XData',[tt,tt]);
		set(phy,'XData',[tt,tt]);
		%set(phz,'XData',[tt,tt]);

		i  % print index value so we can follow progress in the command window
		drawnow

		if makemovie == true
			writeVideo(writerObj,getframe(gcf));
		end  % end makemmovie

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
		%hold on
		%plot(xyz(b,1),vel(b,i)+25,'LineWidth',2)
		%plot(xyz(c,1),vel(c,i)-25,'LineWidth',2)
		grid on
		axis([-.005 .04 -50 50]);
		%hold off

		i
		drawnow
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
	end

elseif viewtype == 6
	% points to look at
	%npos = [100 200 500 800];
	npos = [13 27 100 264 500 648 739 1003];

	% calculate sampling frequency
	dt = mean(diff(t));
	Fs = 1 / dt;

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
end

if makemovie == true
	%movie(M);
	close(writerObj);
end  % end makemovie

