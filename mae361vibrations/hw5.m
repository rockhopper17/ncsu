% Andrew Navratil
% MAE 361 Fall 2018
% HW5
% Due 2018-10-22

% clear all vars and plots
close all; clear all; clc;

% variables to play with - num links, step size, initial conditions
numl = 3;				% number of links (repeated in hw5.m)
L(1:numl) = 1;			% lengths of links [m] (this is repeated in hw5_state.m)

deltaT = 0.00005;		% step size
N = 10/deltaT;			% num steps
numFrameSkip = 100;		% only capture every numFrameSkip'th frame, animation code takes awhile

% initial conditions for numerical integration methods

% 3 link chain initial conditions
x(1) = 0;							% x1
x(2) = L(1);						% y1
x(3) = 0;							% x2
x(4) = L(1) + L(2);					% y2
x(5) = L(3) * sind(10);				% x3
x(6) = L(1) + L(2) + L(3)*cosd(10);	% y3
x(7) = 0;							% x1 dot
x(8) = 0;							% y1 dot
x(9) = 0;							% x2 dot
x(10) = 0;							% y2 dot
x(11) = 0;							% x3 dot
x(12) = 0;							% y3 dot

% 2 link chain initial conditions
%x(1) = 0;						% x1
%x(2) = L(1);					% y1
%x(3) = L(2)*sind(10);			% x2
%x(4) = L(1) + L(2)*cosd(10);	% y2
%x(5) = 0;						% x1 dot
%x(6) = 0;						% y1 dot
%x(7) = 0;						% x2 dot
%x(8) = 0;						% y2 dot

% Runge-Kutta nonlinear
for i = 1:N
	t = (i-1)*deltaT;
	time(i) = t;
	
	xgraph(i,1:numl) = x(1:2:2*numl-1);
	ygraph(i,1:numl) = x(2:2:2*numl);

	% using RK4 integrator	
	x = rk4('hw5_state',x,t,deltaT);
end

% TODO: calculate analytical solution

%if false

% plot x position vs time for tip
fig = figure(1);
colormap(jet);
hold on;
grid on;
title(sprintf('%d-link chain: x position vs time for link %d',numl,numl));
xlabel('time (s)');
ylabel('x position (m)');

plot(time,xgraph(:,numl));

% plot y position vs time for tip
fig2 = figure(2);
colormap(jet); 
hold on;
grid on;
title(sprintf('%d-link chain: y position vs time for link %d',numl,numl));
xlabel('time (s)');
ylabel('y position (m)');

plot(time,ygraph(:,numl));

% plot x position vs y position for tip
fig3 = figure(3);
colormap(jet); 
hold on;
grid on;
title(sprintf('%d-link chain: x position vs y position for link %d',numl,numl));
xlabel('x position (m)');
ylabel('y position (m)');

plot(xgraph(:,numl),ygraph(:,numl));

%end

%if false

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

%end
