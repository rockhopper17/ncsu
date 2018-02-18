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
diamSphere = 0.2032;	% m
tfconst = 3.85e5;		% (dimensionless)
cprecrconst = 1.22;		% pressure coefficient value for looking up critical reynolds number

% from lab 1 - inc vel: Isensor = 0.0121 * Pmanometer + 4.1194
lab1eqnB = 4.1194;		% y-intercept
lab1eqnM = 0.0121;		% slope

%---------------------------------------------------------------------
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

% find a point where the pressure coefficient decreases rapidly by
% interpolating for the Re value at Cp = 1.22
%recridx = cellfun(@(x) findchangepts(x), cp, 'UniformOutput', false);
recr = cellfun(@(re,cp) interp1(cp,re,cprecrconst), re, cp, 'UniformOutput', false);
recr = cell2mat(recr);  % convert to matrix since we have same dimensions now (1x1 essentially)

% calculate the turbulence factor
tf = tfconst ./ recr;

% interpolate to get the percent turbulence value
tpcnt = interp1(dataTFvsPerCentT(:,1),dataTFvsPerCentT(:,2),tf);

% get final tf and tpcnt values for wind tunnel by taking average
tfwt = mean(tf);
tpcntwt = mean(tpcnt);

%---------------------------------------------------------------------
% plot data for cp (deltaP / q) vs re
fig1 = figure(1);
hold on;
grid on;

for i = 1:8
	% plot cp (deltaP / q) vs re, save handle for legend
	leghand(i) = plot(re{i},cp{i},'o-');

	% plot and highlight points for critical reynolds number
	plot(recr(i), cprecrconst,'r*','MarkerSize',12);
end

title('Pressure Coefficient vs Reynolds Number');
xlabel('Reynolds Number');
ylabel('^{\Delta p}/_{q}');

legend([leghand(1) leghand(2) leghand(3) leghand(4) leghand(5) leghand(6) leghand(7) leghand(8)],...
{'Thur r1','Tues r1','Wed s1-r1','Wed s2-r1','Thur r2','Tues r2','Wed s1-r2', 'Wed s2-r2'},...
'Location','Northeast');

text(1.5e5,cprecrconst,'Critical Reynolds Number \rightarrow');

% plot data for TF vs PerCentT, inc critical reynolds numbers found
fig2 = figure(2);
hold on;
grid on;

plot(dataTFvsPerCentT(:,1), dataTFvsPerCentT(:,2));
plot(tf,tpcnt,'ro');
plot(tfwt,tpcntwt,'r*','MarkerSize',12);

title('Percent Turbulence vs Turbulence Factor');
xlabel('TF');
ylabel('% turbulence');

str = sprintf('Average values for WT: TF = %.2f, %% Turbulence = %.2f%%',tfwt, tpcntwt);
text(1.35,tpcntwt,'\leftarrow');
text(1.4,tpcntwt,str);

% save plots to jpg
saveas(fig1,'lab02_cp_vs_re.jpg');
saveas(fig2,'lab02_tf_vs_tpcnt.jpg');
