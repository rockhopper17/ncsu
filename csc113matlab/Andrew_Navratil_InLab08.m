% Name: Andrew Navratil
% Section: 205
% Date: 2017-11-02
% In-Lab 8

clear all; close all; clc % clear functions
%% Instructor-Guided Portion
%% Problem 1 - Warped Checkers
% Copy ALL of the features of the figure and plot shown in the problem.
figClr = [.94 .90 .55]; patchClr = [.126 .70 .67];
axesClr = [.96 .96 .8627];

% Create and edit the figure window
fHandle = figure(1);
hold on;
set(fHandle,'Name','Warped Checkers','Color',figClr);

% Use patch() to plot x and y functions
t = linspace(0,2*pi,200);
x = cos(5*t);
y = sin(8*t);
pHandle = patch(x,y,patchClr);

% Fill the blank spaces by setting the axis background to the specified
% color
set(gca,'Color',axesClr);

% Add labels, title, and origin marker
title('x = cos(5*t), y = sin(8*t), 0<\theta<2\pi');
xlabel('X Axis');
ylabel('Y Axis');
plot(0,0,'*y');
tHandle = text(0,0,'Origin');
set(tHandle,'Color','y');

%% Problem 2 - Adding Animation to Your Resume
% Create an animation using the parametric function x = 2cos(t) + cos(2t)
%                                                   y = 2sin(t) - sin(2t)

% Initialize t:
nSteps = 500;
t = linspace(0, 8*pi, nSteps);

% Calculate set of points for x:
x = 2*cos(t) + cos(2*t);
y = 2*sin(t) - sin(2*t);

% Determine limits of animation as it plots
xLim = [min(x) max(x)];
yLim = [min(y) max(y)];

% Create figure and plot animation:
figure(2);
hold on;

xlim(xLim);
ylim(yLim);

for i = 1:nSteps
	line = plot(x(1:i),y(1:i),'k');
	point = plot(x(i),y(i),'ro');
	pause(0.02);
	drawnow;
	delete(point);
end

%% Problem 3 - Anonymous Functions
% Create an anonymous function:
aFunction = @(x,y) (x^y)/(y^x);

% Call the anonymous function using the given inputs
partA = aFunction(1,2);
partB = aFunction(4,3);
partC = aFunction(0.5,6);

%% Problem 4 - Surfing on Transforms
% Create and edit a 3D plot for Z(x,y) = xsin(x+y) - ycos(x+y)

% Create a new figure
figure(3);

% Define x and y vectors for [0 2*pi]
stp = .01;
x = 0:stp:2*pi;
y = 0:stp:2*pi;

% Generate X and Y matrices for all [x y] in the region bounded by the two
% vectors.
[xMat,yMat] = meshgrid(x,y);

% Calculate Z for all [x y]
zMat = xMat*sin(xMat+yMat) - yMat*cos(xMat-yMat);

% Create surface using surf with x and y vectors and Z(x,y).
surfHandle = surf(xMat,yMat,zMat);

% Turns off edges so you can see the colors!
set(surfHandle,'EdgeColor','none');

% Labels axes
xlabel('X Axis');
ylabel('Y Axis');
zlabel('Z Axis');

% Change colormap and light location
colormap('cool');
camlight('left');
%% Independent Portion 
