% problem 3

% clear all vars and plots close all; clear all; clc;
close all; clear all; clc;

% constants for problem
m0 = 250; % kg
mf = 140; % kg
mfuel = 110; % kg
P02 = 10e6; % Pa
T02 = 2800; % K
Pe = 10e3; % Pa
At = pi*(.1/2)^2; % m^2 (throat)
Ae = pi*(.4/2)^2; % m^2 (exit)
Cf = 2;

Pa = 101325; % Pa
Rbar = 8.314;
gamma = 1.4;
g = 9.81;

% methane
%cp = 0.835*4184; % J/kg K
%m0 = 197; % est fuel mass for 100km

% RP-1
%cp = 0.45*4184; % J/kg K
%m0 = 225;

% liquid hydrogen
cp = 1.75*4184; % J/kg K
%m0 = 178;

% equations
ue = sqrt(2*cp*T02*(1-(Pe/P02)^((gamma-1)/gamma)))
mdot = Cf*P02*At/ue
tb = (m0-mf)/mdot
deltaV = ue*log(m0/mf)
yb = ue*tb - 0.5*g*tb^2 - mf*ue*log(m0/mf)/mdot
ymax = yb + 0.5*(deltaV)^2/g

% plots of thrust and Isp vs altitude

% Pa use formula from engineeringtoolbox.com
h = 0:10:100000; % sea level to 100km
Pa = 101325*(1-(2.25577e-5.*h)).^5.25588;
Pa(Pa<0) = 0;

F = mdot*ue + (Pe-Pa).*Ae; % thrust [N]
Isp = ue/g; % Isp (assume constant mass flow rate)
yyaxis left;
plot(h*1e-3,F*1e-3);
ylabel('Thrust (kN)');
yyaxis right;
yline(Isp);
ylabel('Isp (s)');
%title('Methane');
%title('RP-1');
title('Liquid Hydrogen');
xlabel('Altitude (km)');
set(gca,'FontSize',14);
