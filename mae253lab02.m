% Andrew Navratil
% MAE 253 Spring 2018
% Lab 2 - Wind Tunnel Turbulence Study
% Due 2018-02-19

% clear all vars and plots
close all; clear all; clc;

% Import ALL data
% Column definitions in the Tunnel-Turbulence_Run-*.dat files: P_transducer (psf) | I_sensor (mA)
dataTurb = [];
dataTurb = [dataTurb; load('data/Lab02-Tunnel-Turbulence_Run-1_Thursday-Session_20180208.dat')];
dataTurb = [dataTurb; load('data/Lab02-Tunnel-Turbulence_Run-1_Tuesday-Session_20180206.dat')];
dataTurb = [dataTurb; load('data/Lab02-Tunnel-Turbulence_Run-1_Wednesday-Session-1_20180207.dat')];
dataTurb = [dataTurb; load('data/Lab02-Tunnel-Turbulence_Run-1_Wednesday-Session-2_20180207.dat')];
dataTurb = [dataTurb; load('data/Lab02-Tunnel-Turbulence_Run-2_Thursday-Session_20180208.dat')];
dataTurb = [dataTurb; load('data/Lab02-Tunnel-Turbulence_Run-2_Tuesday-Session_20180206.dat')];
dataTurb = [dataTurb; load('data/Lab02-Tunnel-Turbulence_Run-2_Wednesday-Session-1_20180207.dat')];
dataTurb = [dataTurb; load('data/Lab02-Tunnel-Turbulence_Run-2_Wednesday-Session-2_20180207.dat')];

% Import the data for TF vs PerCentT
% Column definitions in the TF_vs_PerCentT.txt files: Turbulence Factor | Per cent turbulence
dataTFvsPerCentT = load('data/Lab02-TF_vs_PerCentT.txt');

% constants / conversions / coefficients
in_to_m = 0.0254;		% 0.0254 m / 1 in
psf_to_pa = 47.88;		% 47.88 pa / 1 psf
rhoAir = 1.185;			% kg/m^3
muAir = 1.831e-5;		% Ns
g = 9.8;				% m/s^2
diamSphere = 0.2032;	% m

% from lab 1 - inc vel: Isensor = 0.0121 * Pmanometer + 4.1194
lab1eqnB = 4.1194;		% y-intercept
lab1eqnM = 0.0121;		% slope

% calculate delta P from I values using eqn from lab 1 for inc vel to get delta P = P manometer
deltaP = (dataTurb(:,2) - lab1eqnB) ./ lab1eqnM;

% Ptransducer corresponds to freestream dynamic pressure
qinf = dataTurb(:,1) * psf_to_pa;

% calculate freestream velocity using q
vinf = sqrt(2 * qinf ./ rhoAir);

% calculate Reynolds number
re = rhoAir * vinf * diamSphere / muAir;

% calculate pressure coefficient
cp = deltaP ./ qinf;

% plot data for p vs i
fig1 = figure(1);
hold on;
grid on;

xl = [0 1000];		% x range (p values)
yl = [0 20];		% y range (i values)

plot(re,cp,'bo-');

%xlim(xl);
%ylim(yl);

title('Pressure Coefficient vs Reynolds Number');
xlabel('Reynolds Number');
ylabel('\delta p / q');

% save plots to jpg
%saveas(fig1,'lab01_p_vs_i.jpg');

