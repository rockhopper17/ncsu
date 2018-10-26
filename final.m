% Andrew Navratil, Tony Tran
% MAE 361 Fall 2018
% Final Project - planar n-body problem
% Due 2018-11-28

% referencing Orbital Mechanics for Engineering Students, Curtis for physical data

% clear all vars and plots
close all; clear all; clc;

% variables to play with - num links, step size, initial conditions
n = 2;              % number of orbital bodies

deltaT = 1*3600; % step size (hr * s/hr) [s]
N = 30*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)
numFrameSkip = 100;		% only capture every numFrameSkip'th frame, animation code takes awhile

% initial conditions 
x(1) = 0;  % earth - x init
x(2) = 0;  % earth - y init
x(3) = 0;  % moon - x init
x(4) = 384400;  % moon - y init using avg distance to earth [km]
x(5) = 0; % x1 dot
x(6) = 0; % y1 dot
x(7) = -1.022; % x2 dot - mean orbital velocity of moon [km/s]
x(8) = 0; % y2 dot

% main integration loop
% time(i) = vector to hold time values
% xgraph(1:n,i) i = time val, 1:n = x position values for each body at time i
% ygraph(1:n,i) i = time val, 1:n = y position values for each body at time i
for i = 1:N
	t = (i-1)*deltaT;
	time(i) = t;
	
	xgraph(1:n,i) = x(1:2:2*n-1);
	ygraph(1:n,i) = x(2:2:2*n);

	% using RK4 integrator	
	x = rk4('final_state',x,t,deltaT);
end

%if false

% TODO: pick a month and find actual postion values for moon relative to earth
% and plot that next to the numerical simulation

% plot x position vs y position for moon
fig1 = figure(1);
colormap(jet); 
hold on;
grid on;
title(sprintf('%d-body problem: x position vs y position',n));
xlabel('x position (km)');
ylabel('y position (km)');

plot(xgraph(1,:),ygraph(1,:),'.-');
plot(xgraph(2,:),ygraph(2,:),'.-');
legend('earth','moon');

%end

if false

% animation
% only take every 100th frame for animation, it's not changing enough in between to notice
%   otherwise this part of code takes forever
figure(4);
writerObj = VideoWriter('nlink.avi');
writerObj.FrameRate = 1/(deltaT*numFrameSkip);
%writerObj.FrameRate = 30;
open(writerObj);
for i = 1:numFrameSkip:N
	plot(xgraph(i,1),ygraph(i,1),'.','markersize',50);
	hold on;
	line([0 xgraph(i,1)],[0 ygraph(i,1)],'color','black','linewidth',2);
	
	if numl >= 2
		plot(xgraph(i,2),ygraph(i,2),'.','markersize',50);
		line([xgraph(i,1) xgraph(i,2)],[ygraph(i,1) ygraph(i,2)],'color','black','linewidth',2);
	end
	if numl >= 3
		plot(xgraph(i,3),ygraph(i,3),'.','markersize',50);
		line([xgraph(i,2) xgraph(i,3)],[ygraph(i,2) ygraph(i,3)],'color','black','linewidth',2);
	end

	if numl == 2
		axis([-1.25 1.25 0 2.5]);
	end
	if numl == 3
		axis([-2.25 2.25 0 3.5]);
	end
	set(gca,'Ydir','reverse');
	M = getframe;
	writeVideo(writerObj,M);
	hold off;
end

movie(M);
close(writerObj);

end
