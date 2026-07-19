% clear all vars and plots
close all; clear all; clc;

% load all workspace vars
load('svddata.mat');

%>> whos
  %Name         Size                Bytes  Class     Attributes

  %amp_x      317x2500            6340000  double              
  %amp_y      317x2500            6340000  double              
  %amp_z      317x2500            6340000  double              
  %ans          1x1                     8  double              
  %fname        1x13                   26  char                
  %t            1x2500              20000  double              
  %usd_x        1x1                  4681  struct              
  %usd_y        1x1                  4681  struct              
  %usd_z        1x1                  4681  struct              
  %xyz        317x3                  7608  double              

 
% get the initial position and plot
colormap('jet');
%figure('units','normalized','outerposition',[0 0 1 1]);  % make window full screen
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
pos = xyz;
scatter3(pos(:,1), pos(:,2), pos(:,3), 50, 'filled');
%scatter(pos(:,1), pos(:,2));
%plot3(pos(:,1), pos(:,2), pos(:,3),'.','MarkerSize',15);
axis([-.05 .05 -2.5e-3 2.5e-3 -.1 .1]);
%view([0 -10]);  % orient along x-axis tilted down 10 deg

% animation
for i = 1:length(t)-1
%for i = 1:200
	% increment the position based on calculating displacement
	% from the velocity values and the time step
	% velocity values are in amp_[x,y,z] in m/s
	% time value is in t in s
	pos(:,1) = pos(:,1) + (amp_x(:,i) * (t(i+1) - t(i))) * 1e5;
	pos(:,2) = pos(:,2) + (amp_y(:,i) * (t(i+1) - t(i))) * 1e5;
	pos(:,3) = pos(:,3) + (amp_z(:,i) * (t(i+1) - t(i))) * 1e5;

	% calculate the total velocity magnitude
	vel = sqrt(amp_x(:,i).^2 + amp_y(:,i).^2 + amp_z(:,i).^2) * 1e3; % convert to mm/s
	
	scatter3(pos(:,1), pos(:,2), pos(:,3), 50, vel, 'filled');
	%plot3(pos(:,1), pos(:,2), pos(:,3),'.','Color',vel,'MarkerSize',15);
	axis([-.05 .05 -2.5e-3 2.5e-3 -.1 .1]);
	
	%scatter(pos(:,1), pos(:,2), 10, vel, 'filled');
	%axis([-.05 .05 -2.5e-3 2.5e-3]);
	
	%view([0 -10]);  % orient along x-axis tilted down 10 deg

	caxis([0 5]);
	colorbar
	i
	drawnow

end  % end time loop
