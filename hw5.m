% Andrew Navratil
% MAE 361 Fall 2018
% HW5
% Due 2018-10-22

% clear all vars and plots
close all; clear all; clc;

% initial conditions for numerical integration methods
L(1:2) = 1;		% lengths of links [m] (this is repeated in hw5_state.m)
x(1) = 0;		% x1
x(2) = L(1);		% y1
x(3) = L(2)*sind(10);	% x2
x(4) = L(1) + L(2)*cosd(10);	% y2
x(5) = 0;		% x1 dot
x(6) = 0;		% y1 dot
x(7) = 0;		% x2 dot
x(8) = 0;		% y2 dot

deltaT = 0.0005;		% step size
N = 10/deltaT;		% num steps

% Runge-Kutta nonlinear
for i = 1:N
	t = (i-1)*deltaT;
	time(i) = t;
	
	xgraph(i,1) = x(1);
	ygraph(i,1) = x(2);
	xgraph(i,2) = x(3);
	ygraph(i,2) = x(4);
	
	x = step2('hw5_state',x,t,deltaT);
end

% TODO: calculate analytical solution

% plot x position vs time
fig = figure(1);
colormap(jet);
hold on;
grid on;
title('2-link chain: x position vs time');
%xlim([0 6.0]);
%ylim([168 192]);
xlabel('time (s)');
ylabel('x position (m)');

plot(time,xgraph(:,2));

% plot y position vs time
fig2 = figure(2);
colormap(jet); 
hold on;
grid on;
title('2-link chain: y position vs time');
%xlim([0 6.0]);
%ylim([168 192]);
xlabel('time (s)');
ylabel('y position (m)');

plot(time,ygraph(:,2));

% plot x position vs y positio
fig4 = figure(4);
colormap(jet); 
hold on;
grid on;
title('2-link chain: x position vs y position');
%xlim([0 6.0]);
%ylim([168 192]);
xlabel('x position (m)');
ylabel('y position (m)');

plot(xgraph(:,2),ygraph(:,2));


if false

% animation
figure(3);
writerObj = VideoWriter('nlink2.avi');
%writerObj.FrameRate = 1/deltaT;
writerObj.FrameRate = 30;
open(writerObj);
%for i = 1:N
for i = 1:10:N
	plot(xgraph(i,1),ygraph(i,1),'.','markersize',50);
	hold on;
	line([0 xgraph(i,1)],[0 ygraph(i,1)],'color','black','linewidth',2);
	plot(xgraph(i,2),ygraph(i,2),'.','markersize',50);
	line([xgraph(i,1) xgraph(i,2)],[ygraph(i,1) ygraph(i,2)],'color','black','linewidth',2);
	axis([-1.25 1.25 0 2.5]);
	set(gca,'Ydir','reverse');
	M = getframe;
	writeVideo(writerObj,M);
	hold off;
end

movie(M);
close(writerObj);

end
