% scrap code
close all; clear all; clc;

% handout 3

syms x1 x2 c k M;

f = @(x1,x2) (3*k/M)*(1-1/sqrt(3-2*cos(x1)-2*sin(x1)))*(cos(x1)-sin(x1))-(3*c/M)*(sin(x1)+cos(x1)^2)*x2/(3+2*sin(x1)-2*sin(x1));

df = matlabFunction(diff(f,x1));
