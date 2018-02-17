% Andrew Navratil
% MAE 253 Spring 2018
% Lab 2 - Wind Tunnel Turbulence Study
% Due 2018-02-19

% clear all vars and plots
close all; clear all; clc;

% Import ALL data
% Column definitions in the Tunnel-Turbulence_Run-*.dat files: P_transducer (psf) | I_sensor (mA)
dataTurb{1} = load('data/Lab02-Tunnel-Turbulence_Run-1_Thursday-Session_20180208.dat');
dataTurb{2} = load('data/Lab02-Tunnel-Turbulence_Run-1_Tuesday-Session_20180206.dat');
dataTurb{3} = load('data/Lab02-Tunnel-Turbulence_Run-1_Wednesday-Session-1_20180207.dat');
dataTurb{4} = load('data/Lab02-Tunnel-Turbulence_Run-1_Wednesday-Session-2_20180207.dat');
dataTurb{5} = load('data/Lab02-Tunnel-Turbulence_Run-2_Thursday-Session_20180208.dat');
dataTurb{6} = load('data/Lab02-Tunnel-Turbulence_Run-2_Tuesday-Session_20180206.dat');
dataTurb{7} = load('data/Lab02-Tunnel-Turbulence_Run-2_Wednesday-Session-1_20180207.dat');
dataTurb{8} = load('data/Lab02-Tunnel-Turbulence_Run-2_Wednesday-Session-2_20180207.dat');

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
tfconst = 3.85e5;		% (dimensionless)

% from lab 1 - inc vel: Isensor = 0.0121 * Pmanometer + 4.1194
lab1eqnB = 4.1194;		% y-intercept
lab1eqnM = 0.0121;		% slope

% calculate delta P from I values using eqn from lab 1 for inc vel to get delta P = P manometer
deltaP = cellfun(@(x) (x(:,2) - lab1eqnB) ./ lab1eqnM, dataTurb, 'UniformOutput', false);

% Ptransducer corresponds to freestream dynamic pressure
qinf = cellfun(@(x) x(:,1) * psf_to_pa, dataTurb, 'UniformOutput', false);

% calculate freestream velocity using q
vinf = cellfun(@(x) sqrt(2 * x ./ rhoAir), qinf, 'UniformOutput', false);

% calculate Reynolds number
re = cellfun(@(x) rhoAir * x * diamSphere / muAir, vinf, 'UniformOutput', false);

% calculate pressure coefficient
cp = cellfun(@(x,y) x ./ y, deltaP, qinf, 'UniformOutput', false);

% find a point where the pressure coefficient decreases rapidly
% to get the critical reynolds num
recridx = cellfun(@(x) findchangepts(x), cp, 'UniformOutput', false);

% loop to get actual critical reynolds number values and calculate turbulence factor
for i = 1:8
	% lookup reynolds number by index found with findchangepts
	reval = re{i}(recridx{i});

	% lookup the corresponding pressure coefficient (delta P)
	cpval = cp{i}(recridx{i});

	% calculate the turbulence factor
	tfval = tfconst / reval;

	% interpolate to get the percent turbulence value
	tpcntval = interp1(dataTFvsPerCentT(:,1),dataTFvsPerCentT(:,2),tfval);

	% save value pairs to cell arrays for plotting
	recr{i} = [reval,cpval];
	tf{i} = [tfval,tpcntval];
end


% plot data for cp (delta P) vs re
fig1 = figure(1);
hold on;
grid on;

for i = 1:8
	% plot cp (delta P) vs re, save handle for legend
	leghand(i) = plot(re{i},cp{i},'o-');

	% plot and highlight points for critical reynolds number
	plot(recr{i}(1), recr{i}(2),'r*','MarkerSize',12);
end
%plot(re{1}(rec),cp{1}(rec),'*');
legend([leghand(1) leghand(2) leghand(3) leghand(4) leghand(5) leghand(6) leghand(7) leghand(8)],...
{'Thur r1','Tues r1','Wed s1-r1','Wed s2-r1','Thur r2','Tues r2','Wed s1-r2', 'Wed s2-r2'},...
'Location','Northeast'); 

%xlim(xl);
%ylim(yl);

title('Pressure Coefficient vs Reynolds Number');
xlabel('Reynolds Number');
ylabel('^{\Delta p}/_{q}');

% plot data for TF vs PerCentT, inc critical reynolds numbers found
fig2 = figure(2);
hold on;
grid on;

plot(dataTFvsPerCentT(:,1), dataTFvsPerCentT(:,2));
%plot(tf{:},tpcnt,'o');

% save plots to jpg
%saveas(fig1,'lab02_cp_vs_re.jpg');

