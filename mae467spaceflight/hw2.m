% MAE 467 Space Flight - HW2

% clear all vars and plots
close all; clear all; clc;

% set globals used in twobody_state
global G m
G = 6.67259e-20; % universal gravitational constant (km^3/kg/s^2) 
m = [5.974e24 1000]; % mass [kg] (earth, satellite)

% initial position (x y z) [km]
r1 = [0 0 0];
r2 = [3207 5459 2717];

% initial velocity (vx, vy, vz) [km/s]
v1 = [0 0 0];
v2 = [-6.532 0.7835 6.142];

% state space vector of initial conditions
xt = [r1,r2,v1,v2];

% time range [sec]
t0 = 0;
tf = 2*3600;  % hrs * sec/hr = sec
%tspan = [t0 tf];
tspan = [0:2*3600];

% use matlab's ode45 to integrate
[t,x] = ode45('twobody_state', tspan, xt);

% calculate altitude of satellite from sea level [km]
r = sqrt(x(:,4).^2 + x(:,5).^2 + x(:,6).^2) - 6378;

% max altitude of satellite
[rmax,idx] = max(r);

rmax
t(idx)
x(end,4:6)
x(end,10:12)

