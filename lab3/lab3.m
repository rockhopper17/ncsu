% Andrew Navratil
% MAE 451 Expr Aero 3 Fall 2019
% Lab 3 Propeller Analysis
% Due 2019-10-18

% clear all vars and plots
close all; clear all; clc;

% constants
rho = 1.18; % air density [kg/m^3]

in_to_m = 0.0254; % conversion in to m [m/in]
lb_to_kg = 0.4536; % conversion lb to kg [kg/lb]
inlb_to_Nm = 0.113; % conversion in-lb to Nm [in-lb/Nm]
psf_to_pa = 47.88; % conversion for psf to Pascal [Pa/psf]

% load data
data = load('data/Lab-3_prop_data_all_sessions.dat');

propnum = data(:,1); % no. of props
propdiam = data(:,2) * in_to_m; % prop diam [in] to [m]
proppitch = data(:,3) * in_to_m; % prop pitch [in] to [m]
throttle = data(:,4);
uinf = sqrt(2*data(:,5)*psf_to_pa/rho); % vel from qpsf [psf] to [m/s]
volts = data(:,6);
amps = data(:,7);
thrust = data(:,8) * lb_to_kg; % thrust [lb] to [kg]
torque = data(:,9) * inlb_to_Nm; % toreque [in-lb] to [Nm]
rpm = data(:,10);
material = data(:,11); % material (1 - APC, 2 - Wood)

% calculate characteristics
J = uinf ./ (rpm .* propdiam); % advanced ratio
CT = thrust ./ (rho * rpm.^2 .* propdiam.^4); % thrust coeff
CQ = torque ./ (rho * rpm.^2 .* propdiam.^5); % torque coeff
CP = (volts .* amps) ./ (rho * rpm.^3 .* propdiam.^5); % power coeff
eta = CT .* J ./ (2*pi * CQ);

% get list of unique propellers
combocols = [propnum  propdiam proppitch];
[B,~,ib] = unique(combocols,'rows');
numoccurrences = accumarray(ib,1);
propsidx = accumarray(ib, find(ib), [], @(rows){rows});

