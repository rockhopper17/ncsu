% Andrew Navratil
% MAE 435 Controls
% HW 6
% Due 11/7/2019

% clear all vars and plots
close all; clear all; clc;

% use s method for writing transfer functions
s = tf('s');

% check num 2
%tf1 = 1/(s*(s^2+3*s+10))

%pole(tf1)
%figure;
%rlocus(tf1)

%tf2 = (s^2+2*s+8)/(s*(s^2+2*s+10))

%pole(tf2)
%zero(tf2)
%figure;
%rlocus(tf2)

% problem 4
%K = 1
%tf3 = K/(s*(s+4)*(s+6))
K = 47.2
z0 = 3
tf3 = (K*(s+z0))/(s*(s+4)*(s+6))
%K = 2
%z0 = 18
%tf3 = (K*(s+z0))/(s*(s+2))

pole(tf3)
zero(tf3)
figure;
rlocus(tf3)

%http://undocumentedmatlab.com/blog/controlling-plot-data-tips
% First get the figure's data-cursor mode, activate it, and set some of its properties
%cursorMode = datacursormode(gcf);
%set(cursorMode, 'enable','on', 'UpdateFcn',@setDataTipTxt);
% Delete all data-tips
%cursorMode.removeAllDataCursors()
