close all; clear all; clc;

x = [-4:.1:4];
y = normpdf(x,0,1);
plot(x,y);
d=[x;y];
writematrix(d','gaussdist.txt');
