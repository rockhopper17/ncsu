% MAE 467 Space Flight - HW2

% clear all vars and plots
close all; clear all; clc;

% ****************************************
% constants repeated in odeorbits.c
%n = 2;  % number of bodies total
%ndim = 3; % num dimensions (2D: x,y)
%deltaT = 1; % step size [sec]
%runtime = 4*3600;  % total time to run sim [hrs * sec/hr = sec]
%N = runtime / deltaT; % total number of iterations to run integration

%m = zeros(1,n); % mass [kg]
%m(1) = 5.974e24;  % earth
%m(2) = 1000;  % satellite

%G = 6.67259e-20; % universal gravitational constant (km^3/kg/s^2) 
%nvals = 2*n*ndim;  % total number of values in state space vector
% ****************************************

% set globals used in twobody_state
global G m

G = 6.67259e-20; % universal gravitational constant (km^3/kg/s^2) 

m = zeros(1,n); % mass [kg]
m(1) = 5.974e24;  % earth
m(2) = 1000;  % satellite

% initial position (x y z) [km]
r1 = [0 0 0];
r2 = [3207 5459 2717];

% initial velocity (vx, vy, vz) [km/s]
v1 = [0 0 0];
v2 = [-6.532 0.7835 6.142];

% state space vector of initial conditions
xt = [r1,r2,v1,v2];

%*****************************
% init time and x (state space) arrays
%t = zeros(1,N);  % time values

% temp state space vector so we can keep contiguous memory in C (2D array in a 1D array)
%x2 = zeros(1,N*nvals);

% *** call c func odeorbits ***
%[t,x2] = odeorbits(xt);

% get counts
%N = numel(t);
%x = zeros(N,nvals);  % state space vector for all times

% convert the 1D 2D array back into our 2D array for later use
%for i = 1:N
	%x(i,:) = x2((i-1)*nvals+1:(i-1)*nvals + nvals);
%end
%*****************************

[t,x] = odeorbits(xt);

% calculate altitude of satellite from sea level [km]
r = sqrt(x(:,4).^2 + x(:,5).^2 + x(:,6).^2) - 6378;


