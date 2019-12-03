% clear all vars and plots
close all; clear all; clc;

% use s method for writing transfer functions
s = tf('s');

% given fixed parameters
M1 = 10e6; % metric tons converted to kg
k1 = 250e6; % N/m
b1 = 250e3; % N*s/m

% tuned by proj.m
M2 = 0.1*M1;
k2 = 0.1*k1;
b2 = 10*b1;
%k2 = 19952535;
%b2 = 2137605;

H1 = (1/M1)/(s^2+(b1/M1)*s+(k1/M1))

% using full state space model with both F(t) and a(t)
A = [0 1 0 0; -(k1+k2)/M1 -(b1+b2)/M1 k2/M1 b2/M1; 0 0 0 1;...
	k2/M2 b2/M2 -k2/M2 -b2/M2];
B = [0 0; 1/M1 -1/M1; 0 0; 0 1/M2];
C = [1 0 0 0]; % one output: x1
D = [0 0]; % two inputs; F a
sys = ss(A,B,C,D);
[snum,sden] = ss2tf(double(sys.A),double(sys.B),double(sys.C),double(sys.D),1); % X1/F
tfw = tf(snum,sden)
[snum,sden] = ss2tf(double(sys.A),double(sys.B),double(sys.C),double(sys.D),2); % X1/a
%tfa = tf(snum,sden)
tfa = tf([-1e-07 0 0],sden)

% want stable at high gain for disturbance rejection
% want integrator for no steady state error
% want derivative to reduce damping

