% Andrew Navratil
% 2017-11-09
% Section #205
% Homework 8

function plotVarLineWidth( x, y, line_width, color)
% Plots y vs x of the specified line width and color
% Input:	x, y data points
%			line_width is the width of the line to use
%			color is an RGB color

% first create a new figure
figure(1);

% call plot and get handle for setting options 
pHandle = plot(x,y);

% set title, make font a little bigger
tval = sprintf('Line Width = %d, Color = %s',line_width,color);
title(tval,'FontSize',14);

% set options (could put in plot command, but getting practice with handles)
set(pHandle,'color',color);
set(pHandle,'LineWidth',line_width);

end
