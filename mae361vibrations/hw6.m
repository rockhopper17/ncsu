% Andrew Navratil
% MAE 361 Fall 2018
% HW6
% Due 2018-11-05

% clear all vars and plots
close all; clear all; clc;

% variables to play with - num links, step size, initial conditions
deltaT = 0.05;		% step size
N = 10/deltaT;			% num steps
numFrameSkip = 100;		% only capture every numFrameSkip'th frame, animation code takes awhile

% initial conditions for numerical integration methods

x = [0 -.5 0 0];

% integration loop
for i = 1:N
	t = (i-1)*deltaT;
	tvals(i) = t;
	
	thetavals(i) = x(1)*180/pi;
	xvals(i) = x(2);

	x = rk4('hw6_state',x,t,deltaT);
end

% plot theta
figure;
hold on;
grid on;
plot(tvals,thetavals);
title('theta val');
xlabel('time (s)');
ylabel('theta value (deg)');

% plot x
figure;
hold on;
grid on;
plot(tvals,xvals);
title('x val');
xlabel('time (s)');
ylabel('x value (m)');

% plot analytical slns
figure;
fplot(@(t) -2.2*cos(t) + .7*cos(2*t) + 1.5,[0 10]);
grid on;
figure;
fplot(@(t) -4.4*cos(t) - .35*cos(2*t) + 4.25,[0 10]);
grid on;

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
