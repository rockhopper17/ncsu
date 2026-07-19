% Andrew Navratil
% MAE 352 Expr Aero 2 Spring 2019
% Lab 1 Supersonic Wind Tunnel Block Calibration
% Due 2019-02-04

% clear all vars and plots
close all; clear all; clc;

%Column definitions in the provided 'calibration_*.txt' data files:
%time (s) | P_01 (psi) | P_1 (psi) | P_02 (psi) | Patm (psi) | T_01 (degree F)
%Column definitions in 'manufacturer_calibration_curve_supersonic_tunnel.txt':
%Block Setting | Mach Number

%Notes (from readme.txt):
%- The file names correspond to the block settings at which the data was collected.
%- 'manufacturer_calibration_curve_supersonic_tunnel.txt' contains the manufacturers calibration curve.
%- All recorded pressures are gauge pressures. Remember to add the atmospheric pressure during your analysis.
%- Only consider data beyond 2.5 seconds of run time. This is due to the fact that it takes the flow that amount of time to reach the pre-set freestream stagnation pressure (P_01) of 60 psi.
%- Suggestion - In order to get the solution for the Mach number from the Rayleigh Pitot equation, you can use, fsolve(), the in-built Newton-iterator in MATLAB. More information on the implementation of the same can be found on MATLAB's on-line documentation.
%- The report needs to be in the AIAA prescribed format.
%- All results in your final report need to be in SI units.
%- As discussed in the lab, focus on critial analysis. Point out and discuss interesting trends (if any) in the data.
%- In order to get the extra credit, you will have to present detailed analysis and plots. 

% constants / conversions / coefficients
%gamma = 1.4;  % ratio spec heats for air @stp - calculated out values for efficiency and code readability

% data folder name
% looked at data from other sessions to see if they also had the anomalous first two points: they do
datafldr = 'dataTues';
%datafldr = 'dataWed';
%datafldr = 'dataThur';

% block numbers corresponding to file names
blocknums = [400:200:2600];
numb = numel(blocknums);

% prealloate arrays to hold all mach numbers for isentropic and rayleigh methods
M_isen = zeros(1,numb);
M_rayl = zeros(1,numb);

% anon funcs for isentropic and rayleigh methods, calculating out gamma terms
f_isen = @(M,patm,p1,p01) (1 + 0.2*M^2)^(3.5) - ((p01+patm) / (p1+patm));
f_rayl = @(M,patm,p1,p02) ( (5.76*M^2) / (5.6*M^2 - 0.8) )^(3.5) * ...
	((2.8*M^2 - 0.4) / 2.4) - ((p02+patm) / (p1+patm));

% options for fsolve to turn off display messages
opts = optimset('Diagnostics','off', 'Display','off');

% iterate all files appending block number
for bidx = 1:numb 
	% import data, load will auto remove two header rows
	d = load(sprintf('%s/calibration_%d.txt',datafldr,blocknums(bidx)));

	% remove all rows before 2.5 seconds
	d(d(:,1) < 2.5, :) = [];
	[numrows,numccols] = size(d);

	% variables to hold sum of all Ms for averaging after looping
	sum_M_isen = 0;
	sum_M_rayl = 0;

	% loop all rows in data file and calculate mach number
	for i = 1:numrows
		% use fsolve on both functions, using 2 as our guess value 
		sum_M_isen = sum_M_isen + fsolve(@(M) f_isen(M,d(i,5),d(i,3),d(i,2)), 2, opts);
		sum_M_rayl = sum_M_rayl + fsolve(@(M) f_rayl(M,d(i,5),d(i,3),d(i,4)), 2, opts);
	end

	% average the value for each method and stick in the overall arrays
	M_isen(bidx) = sum_M_isen / numrows;
	M_rayl(bidx) = sum_M_rayl / numrows;
end

% import manufacturer data
dman = load(sprintf('%s/manufacturer_calibration_curve_supersonic_tunnel.txt',datafldr));

% perform some analysis on polynomial degree fits
% loop a bunch of degrees, calc R-squared value, but also look at plot
% turns out 8 provides the best rsq, as N-1 (10 - 1 = 9) gave rsq = 1 and an error msg, as did larger nums
% however 3 gives the best curve fit for the lower block numbers
%for i = 2:12
	%[coeff_isen, ~, mu_isen] = polyfit(blocknums(3:end),M_isen(3:end),i);
	%f = polyval(coeff_isen,blocknums,[],mu_isen);
	%yresid = M_isen(3:end) - f(3:end);
	%SSresid = sum(yresid.^2);
	%SStotal = (length(M_isen(3:end))-1) * var(M_isen(3:end));
	%rsq = 1 - SSresid/SStotal;

	%% display the degree and rsq value to output window
	%i
	%rsq	
%end

% best fit polynomials (ignoring first two data points for polyfit, but plotting full range with polyval)
degbest = 3;
[coeff_isen, ~, mu_isen] = polyfit(blocknums(3:end),M_isen(3:end),degbest);
[coeff_rayl, ~, mu_rayl]  = polyfit(blocknums(3:end),M_rayl(3:end),degbest);

blockrange = [50:50:2600];  % set this so we can evaluate all manufacturer points and our points
f_isen = polyval(coeff_isen,blockrange,[],mu_isen);
f_rayl = polyval(coeff_rayl,blockrange,[],mu_rayl);

% plot
ph = gobjects(3);  % init plot handle array
figure;
hold on;
grid on;

plot(blocknums,M_isen,'ob');
ph(1) = plot(blockrange,f_isen,'-b');
plot(blocknums,M_rayl,'or');
ph(2) = plot(blockrange,f_rayl,'-r');
ph(3) = plot(dman(:,1),dman(:,2));

title('Mach Number vs Block Setting for deg 3 with rsq 0.998413205794275');
xlabel('Block Number');
ylabel('M_{\infty}');
legend([ph(1) ph(2) ph(3)],{'M_{isentropic}','M_{rayleigh}','M_{manufacturer}'});

