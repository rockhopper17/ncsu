% Andrew Navratil
% 2017-11-09
% Section #205
% Homework 8

clear;close all;clc;

%% 1. anonymous function for area of circular section

% create the anonymous function
areaFunc = @(radius,secangle) 0.5 * radius^2 * secangle;

% test call
% areaFunc(2,pi/2);

%% 2. recursive mypower function

% test call
% val = mypower(2,8);

%% 3. EOsort function with optional output

% test call
% [c,t] = EOsort(1:1000000);

%% 4. plotVarLineWidth function

% test call
% x = linspace(0,2*pi,360);
% y = sin(x);
% plotVarLineWidth(x,y,6,'[0.1 0.2 0.3]');

%% 5. animated plot

% create new figure and get handle
fHandle = figure(1);

% set hold on to leave trail of points
hold on;

% set figure color to grey
set(fHandle,'color','[0.5 0.5 0.5]');

% set axis background to black
set(gca,'color','k');

% looks like we have about 75 points
nSteps = 75;

% initialize x, y values for y = sin(x)
x = linspace(0,2*pi,nSteps);
y = sin(x);

% set limit values
xlim([min(x) max(x)]);
ylim([min(y) max(y)]);

% plot y = sin(x) animation with pentagrams as points
for i = 1:nSteps
	plot(x(i),y(i),'p');
	pause(0.05);
	drawnow;
end

