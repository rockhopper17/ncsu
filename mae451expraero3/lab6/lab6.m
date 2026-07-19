% clear all vars and plots
close all; clear all; clc;

% constants
rho = 1.18; % air density [kg/m^3]
Qhv = 11.3e6; % fuel heating value [J/kg]
g = 9.8; % accel due to gravity [m/s^2]
etaC = 0.99; % combustion efficiency
r = 0.4445; % length of lever [m]

in_to_m = 0.0254; % conversion in to m [m/in]
lb_to_N = 4.4482; % conversion lb to N [N/lb]
inlb_to_Nm = 0.113; % conversion in-lb to Nm [in-lb/Nm]
psf_to_pa = 47.88; % conversion for psf to Pascal [Pa/psf]
%ms_to_ins = 39.37; % velocity conversion [m/s] to [in/s]
gms_to_N = 9.807e-3; % conversion g to N [N/g]
cm3_to_m3 = 1e-6; % conversion cubic centimeter to m^3 [m^3/cc^3]

% airframe 1 data
vel(1) = 40; % max operating velocity [m/s]
CD0(1) =0.01; % zero-lift drag coeff
S(1) = 0.5; % wing area [m^2]
m(1) = 3; % take off mass [kg]
e(1) = 0.8; % Oswald efficiency factor
AR(1) = 3; % aspect ratio
tflight(1) = 15*60; % flight time min to sec [s]

% airframe 2 data
vel(2) = 60; % max operating velocity [m/s]
CD0(2) =0.018; % zero-lift drag coeff
S(2) = 0.8; % wing area [m^2]
m(2) = 10; % take off mass [kg]
e(2) = 0.6; % Oswald efficiency factor
AR(2) = 5; % aspect ratio
tflight(2) = 30*60; % flight time min to sec [s]

% data inits, note that motors 1 and 2 map to electric, 3 is gas
maxpow(1:3) = 0;
n(1:3) = 0;
mdotf(1:3) = 0;

%******************************************************************************
% load data for lab 3: 7 propellers
%******************************************************************************
data = load('data/Lab-3_prop_data_all_sessions_clean.dat');

% get list of unique propellers before converting to SI units
combocols = [data(:,1) data(:,2) data(:,3)];
[B,~,ib] = unique(combocols,'rows');
%numoccurrences = accumarray(ib,1);
propsidx = accumarray(ib, find(ib), [], @(rows){rows});

propnum = data(:,1); % no. of props
propdiam = data(:,2) * in_to_m; % prop diam [in]
proppitch = data(:,3) * in_to_m; % prop pitch [in]
throttle = data(:,4);
uinf = sqrt(2*data(:,5)*psf_to_pa/rho); % vel from qpsf [psf]
volts = data(:,6);
amps = data(:,7);
thrust = data(:,8) * lb_to_N; % thrust [lb]
torque = data(:,9) * inlb_to_Nm; % torque [in-lb]
rotpersec = data(:,10)/60; % rpm to rotations/sec
material = data(:,11); % material (1 - APC, 2 - Wood)

% calculate characteristics
J = uinf ./ (rotpersec .* propdiam); % advanced ratio
CT = thrust ./ (rho * rotpersec.^2 .* propdiam.^4); % thrust coeff
CQ = torque ./ (rho * rotpersec.^2 .* propdiam.^5); % torque coeff
CP = (volts .* amps) ./ (rho * rotpersec.^3 .* propdiam.^5); % power coeff

etaCT = CT;
%etaCT(etaCT<0) = 0; % set negative thrusts to zero for efficiency calculation
eta = etaCT .* J ./ (2*pi * CQ);

% ignore efficiency data after propeller region
nidx = find(thrust<0);

% plots for each propeller (7 plots)
% this is just to check the polyfit
%for idx = 1:length(B)
	%pidxall = propsidx{idx};
	%pidxall = setdiff(pidxall,nidx);
	%[coeff, ~, mu] = polyfit(J(pidxall),eta(pidxall),3);
	%etabyJ = polyval(coeff,J(pidxall),[],mu);

	%figure;
	%plot(J(pidxall),eta(pidxall),'cv','DisplayName','\eta','LineWidth',2);
	%hold on;
	%plot(J(pidxall),etabyJ,'gv','DisplayName','\eta polyfit','LineWidth',2);
	%ylabel('\eta');
	%xlabel('J');
	%title(['APC Propeller: ' num2str(B(idx,2)) ' x ' num2str(B(idx,3)) ' ('...
		%num2str(B(idx,1)) ' blades)']);
	%set(gca,'FontSize',14);
	%legend('location','northeast');
%end

%******************************************************************************
% load data for lab 4: 1 gas motor
%******************************************************************************
data = load('data/Lab-4_Thursday-Session-Data_20191017.dat');

rpm = [data(:,1) data(:,2) data(:,3) data(:,4) data(:,5)];
force = [data(:,6) data(:,7) data(:,8) data(:,9) data(:,10)];
forcecorr = data(:,11);
fueltime = data(:,12);

% calculations
rpmavg = mean(rpm,2)/2; % divide in half for two blades
forceavg = mean(force - forcecorr,2) * gms_to_N;
torque = forceavg * r;
power = 2*pi * (rpmavg/60) .* torque;
fuelmdot = rho * 10 * cm3_to_m3 ./ fueltime;
etaTh = power ./ (fuelmdot * Qhv * etaC);

[rpmavg, sortidx] = sort(rpmavg);
torque = torque(sortidx,:);
power = power(sortidx,:);
etaTh = etaTh(sortidx,:);

% find max power and rotpersec for this motor (gas motor = 3)
[maxpow(3),maxpowidx] = max(power);
n(3) = rpmavg(maxpowidx)/60;
mdotf(3) = fuelmdot(maxpowidx);

%******************************************************************************
% load data for lab 5: 2 electric motors
%******************************************************************************
files = dir('data/motor*.dat');

for idx = 1:numel(files)
	fname = files(idx).name;
	data = load(fullfile(files(idx).folder, fname));

	rpm = data(:,1); 
	torque = data(:,2)/1e3; % data:N-mm convert:N-m
	volts = data(:,3);
	amps = data(:,4);
	%mr = strcat('M',num2str(fname(6)),' R',num2str(fname(11)));
	mnum = str2num(fname(6));

	powin = volts .* amps;
	powout = 2*pi*(rpm/60).*torque; % data:rpm convert:rps
	eff = powout./powin;

	% find max power and rotpersec for this motor
	[maxpowcur,maxpowidx] = max(powout);
	if (maxpowcur > maxpow(mnum))
		maxpow(mnum) = maxpowcur;
		n(mnum) = rpm(maxpowidx)/60;

		% calculate fuel mass flow rate
		mdotf(idx) = powin(maxpowidx)/(Qhv*etaC);
	end
end

%******************************************************************************
% create power curves for each airframe
% 2 airframes, 3 motors, 7 propellers = 42 plots
%******************************************************************************
figidx = 1;
for fidx = 1:2

minEdiff = 1e8; % min diff endur theo vs exp
minRdiff = 1e8; % min diff range theo vs exp
maxRC = 0; % max rate climb exp
maxidx(1:6) = ones(6,1); % e midx, e pidx, r midx, r pidx, rc midx, rc pidx

for midx = 1:3
for pidx = 1:7

v = [0:0.01:vel(fidx)];
%v = [0:vel(fidx)];

figure(figidx);
figidx = figidx + 1;

% power required
preq = 0.5*rho*v.^3*CD0(fidx)*S(fidx);
preq = preq + (m(fidx)^2./(0.5*rho*v*S(fidx))) * (1/(pi*e(fidx)*AR(fidx)));

plot(v,preq,'--','Color',[0.5 0.5 0.5],'DisplayName','P_{required}','LineWidth',2);
hold on;

% power available
pidxall = propsidx{pidx};
pidxall = setdiff(pidxall,nidx); % ignore zero thrust (after prop region)
[coeff, ~, mu] = polyfit(J(pidxall),eta(pidxall),3);
Jopr = v./(n(midx)*propdiam(pidxall(1)));
etabyv = polyval(coeff,Jopr,[],mu);

pavbl = etabyv * maxpow(midx);

plot(v,pavbl,'-','Color',[0.5 0.5 0.5],'DisplayName','P_{available}','LineWidth',2);

% min drag line
beta = atan(min(preq./v));
plot(v,beta*v,'--','Color',[0.8500 0.3250 0.0980],'DisplayName','Min. Drag Line','LineWidth',2);

% max theoretical endurance
[~,maxEtheoIdx] = min(preq);
xline(v(maxEtheoIdx),'k-','DisplayName','Theo. E_{max}','LineWidth',2);

% max theoretical range
[~,maxRtheoIdx] = min(preq-(beta*v));
xline(v(maxRtheoIdx),'k--','DisplayName','Theo. R_{max}','LineWidth',2);

% max endurance, range, rate of climb
W1 = m(fidx)*g;
cp = mdotf(midx)*g/maxpow(midx);
CL = W1./(0.5*rho*v.^2*S(fidx));
CD = CD0(fidx) + CL.^2./(pi*e(fidx)*AR(fidx));
W2 = W1 - (tflight(fidx)*mdotf(midx)*g);
E = (etabyv./cp).*sqrt(2*rho*S(fidx)).*(CL.^(3/2)./CD).*(W2^(-1/2)-W1^(-1/2));
R = (etabyv./cp).*(CL./CD).*log(W1./W2);
RC = (pavbl-preq)./W1;

[~,maxEexpIdx] = max(E);
xline(v(maxEexpIdx),'r--','DisplayName','Max. Endurance','LineWidth',2);
[~,maxRexpIdx] = max(R);
xline(v(maxRexpIdx),'b--','DisplayName','Max. Range','LineWidth',2);
[~,maxRCexpIdx] = max(RC);
xline(v(maxRCexpIdx),'--','Color',[0.4660 0.6740 0.1880],...
	'DisplayName','Max. R/C','LineWidth',2);

% plot labels
title(sprintf('Airframe %d Motor %d Propeller %sx%d (%d blades)'...
	,fidx,midx,num2str(B(pidx,2)),B(pidx,3),B(pidx,1)));
ylabel('Power (W)');
xlabel('Velocity (m/s)');
ylim([0 500]);
legend('location','northeast');
set(gca,'FontSize',14);
saveas(gcf,sprintf('a%dm%dp%d.jpg',fidx,midx,pidx));

% check for best endurance, range, rate of climb
disp(sprintf('motor %d prop %d maxEtheo %f maxEexp %f',midx,pidx,E(maxEtheoIdx),E(maxEexpIdx)));
disp(sprintf('motor %d prop %d maxRtheo %f maxRexp %f',midx,pidx,R(maxRtheoIdx),R(maxRexpIdx)));
disp(sprintf('motor %d prop %d maxRC %f',midx,pidx,RC(maxRCexpIdx)));
diffE = abs(E(maxEtheoIdx) - E(maxEexpIdx));
diffR = abs(R(maxRtheoIdx) - R(maxRexpIdx));
if (diffE < minEdiff)
	maxidx(1) = midx;
	maxidx(2) = pidx;
	minEdiff = diffE;
end
if (diffR < minRdiff)
	maxidx(3) = midx;
	maxidx(4) = pidx;
	minRdiff = diffR;
end
if (RC(maxRCexpIdx) > maxRC)
	maxidx(5) = midx;
	maxidx(6) = pidx;
	maxRC = RC(maxRCexpIdx);
end

end % end propeller loop
end % end motor loop

%maxidx(1:6) -> e midx, e pidx, r midx, r pidx, rc midx, rc pidx
disp(sprintf('aiframe %d',fidx));
disp(sprintf('best endurance: motor %d prop %d',maxidx(1),maxidx(2)));
disp(sprintf('best range: motor %d prop %d',maxidx(3),maxidx(4)));
disp(sprintf('best rate of climb: motor %d prop %d',maxidx(5),maxidx(6)));

end % end airframe loop

