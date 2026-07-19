% Andrew Navratil
% MAE 435 Controls
% HW 4
% Due 2019-10-22

% clear all vars and plots
close all; clear all; clc;

% use s method for writing transfer functions
s = tf('s');

% 1(b)(i)
tf1 = (2*s + 8) / (s^3 + s^2 + 2*s + 8);

figure;
pzmap(tf1);
xlim([-5 1]);
ylim([-3 3]);

% 1(b)(ii)
tf2 = (4*s^3 + 8*s^2 + 4*s + 4) / (s^5 + 2*s^4 + 3*s^3 + 7*s^2 + 4*s + 4);

figure;
pzmap(tf2);
