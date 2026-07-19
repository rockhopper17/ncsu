% Andrew Navratil and Kirby Hullender
% MAE 467 Final Project
% Due: 4/24/2019

% clear all vars and plots
close all; clear all; clc;
%
% constants
mu = 398600; % mu for earth [km^3/s^2]
%%
%*****************************************************************************%
% Task 1: Exploring Hohmann transfers between elliptical orbits
%*****************************************************************************%

% local constants
rA = 40000; % given rA [km]

% Plot 1: rA'/rA = 5
% Plot 2: rA'/rA = 1 (circle)
% Plot 3: rA'/rA = 1/5
for pidx = 1:3
	% given parameters for each plot 1 - 3
	if pidx == 1
		rAprA = 5; % rA'/rA
		rBrA = [5.5:0.1:10]; % rB/rA for x axis
		rBprA = [1.5:0.1:10]'; % rB'/rA for y axis
		zlevels = [1.0:0.05:1.5]; % contour levels / z values
	elseif pidx == 2
		rAprA = 1; % rA'/rA
		rBrA = [2.0:0.1:10]; % rB/rA for x axis
		rBprA = [2.0:0.1:10]'; % rB'/rA for y axis
		zlevels = [0.85:0.05:1.3]; % contour levels / z values
	elseif pidx == 3
		rAprA = 1/5; % rA'/rA
		rBrA = [1.5:0.1:10]; % rB/rA for x axis
		rBprA = [1.5:0.1:10]'; % rB'/rA for y axis
		zlevels = [0.4:0.05:1.0]; % contour levels / z values
	end

	% calculate individual position vectors from ratios
	rAp = rAprA * rA; % 1x1
	rB = rBrA * rA; % 1xn
	rBp = rBprA * rA; % mx1

	% calculate Hohmann transfer for A-B (see book p304-305)
	h1 = sqrt(2*mu) * sqrt( (rA*rAp) / (rA+rAp) ); % 1x1
	h2 = sqrt(2*mu) * sqrt( (rBp*rB) ./ (rBp+rB) ); % mxn
	h3 = sqrt(2*mu) * sqrt( (rA*rB) ./ (rA+rB) ); % 1xn
	h3p = sqrt(2*mu) * sqrt( (rAp*rBp) ./ (rAp+rBp) ); % mx1

	% individual velocities at A,A',B
	vA1 = h1 / rA; % 1x1
	vA3 = h3 / rA; % 1xn
	vB2 = h2 ./ rB; % mxn
	vB3 = h3 ./ rB; % 1xn
	vAp1 = h1 / rAp; % 1x1
	vAp3p = h3p / rAp; % mx1
	vBp2 = h2 ./ rBp; % mxn
	vBp3p = h3p ./ rBp; % mx1

	% delta v's
	dvA = abs(vA3 - vA1); % 1xn
	dvAp = abs(vAp3p - vAp1); % mx1
	dvB = abs(vB2 - vB3); % mxn
	dvBp = abs(vBp2 - vBp3p); % mxn

	% total delta v
	dv3 = dvA + dvB; % mxn
	dv3p = dvAp + dvBp; % mxn

	% contour plot
	figure;
	contourf(rBrA,rBprA,dv3p./dv3,zlevels,'ShowText','on');
	ylabel('rB''/rA');
	xlabel('rB/rA');
	title(['rA''/rA = ' num2str(rAprA)]);
	set(gca,'FontSize',14);
	colormap('jet');
	colorbar;

	% save plot to file
	%saveas(gca,['task1plot' num2str(pidx) '.jpg']);
end

%*****************************************************************************%
% Task 2: Exploring node location tradeoffs in a Bi-elliptic transfer
%*****************************************************************************%

% local constants
r1 = 7000; % initial circular orbit radius [km]
r4 = 140000; % target circular orbit radius [km]

% Hohmann transfer 1-4
% r1 = perigee, r4 = apogee of transfer orbit
e14 = (r4 - r1) / (r4 + r1); % eccentricity
h14 = sqrt(r1 * mu * (1 + e14)); % specific angular momentum
a14 = r1 / (1 - e14); % semi major axis
T14 = (2*pi*a14^(3/2))/sqrt(mu); % period [s]

% calculate delta v [km/s] and flight time [days]
v1 = sqrt(mu/r1);
vA14 = h14 / r1; % velocity on A at transfer 
vD14 = h14 / r4; % velocity on D at transfer
v4 = sqrt(mu/r4);

disp('Hohmann transfer delta v and flight time');
dvA = vA14 - v1;
dvD = v4 - vD14;
dv14 = abs(dvA) + abs(dvD) % total delta v
t14 = 0.5*T14/(60*60*24) % convert time to days

% calculate a range of values for Bielliptic transfers
rBrange = [145000:5000:500000];
numrB = numel(rBrange);
% pre-allocations
dvbi = zeros(1,numrB);
tbi = zeros(1,numrB);
dvdec = zeros(1,numrB);
tinc = zeros(1,numrB);

for idx = 1:numrB
	rB = rBrange(idx);

	e2 = (rB - r1) / (rB + r1);
	h2 = sqrt(r1 * mu * (1 + e2));
	a2 = r1 / (1 - e2);
	T2 = (2*pi*a2^(3/2))/sqrt(mu);
	
	e3 = (rB - r4) / (rB + r4);
	h3 = sqrt(r4 * mu * (1 + e3));
	a3 = r4 / (1 - e3);
	T3 = (2*pi*a3^(3/2))/sqrt(mu);

	vA2 = h2 / r1;
	vB2 = h2 / rB;
	vB3 = h3 / rB;
	vC3 = h3 / r4;

	dvA = vA2 - v1;
	dvB = vB3 - vB2;
	dvC = v4 - vC3;

	dvbi(idx) = abs(dvA) + abs(dvB) + abs(dvC);
	tbi(idx) = (0.5*T2 + 0.5*T3)/(60*60*24);
	dvdec(idx) = (dv14 - dvbi(idx))*100/dv14;
	tinc(idx) = (tbi(idx) - t14)*100/t14;
end

%disp('Bi-elliptic transfer delta v and flight time');
% %dvbi
% tbi
% dvdec
% tinc

% plot for delta-v vs flight time
figure;
plot(dv14,t14,'r*','DisplayName','Hohmann transfer');
hold on; grid on;
plot(dvbi,tbi,'b-','DisplayName','Bi-elliptic transfers');
ylabel('total flight time [days]');
xlabel('delta-v required [km/s]');
title({'Comparison of delta-v and flight times for Hohmann and Bi-elliptic','7000km orbit to 14000km orbit'});
set(gca,'FontSize',14);
legend show;

% save plot to file
%saveas(gca,'task2plot1.jpg');

% plot for percent dec delta-v vs percent inc flight time
figure;
plot(dvdec,tinc,'b-','DisplayName','Bi-elliptic transfers');
hold on; grid on;
ylabel('percent increase total flight time [%]');
xlabel('percent decrease delta-v required [%]');
title({'Percent increase flight time vs percent decrease delta-v','Bi-elliptic against Hohmann'});
set(gca,'FontSize',14);

% save plot to file
%saveas(gca,'task2plot2.jpg');

%%
%*****************************************************************************%
% Task 3: Exploring Chase Maneuvers
%*****************************************************************************%

% determine the total delta_v required for Spacecraft B
rp_orb1 = 8100;
ra_orb1 = 18900;
%
% Both B and C are at geocentric elliptical orbits
Btheta = 45;
Ctheta = 150;
%
% Orbit 1 Attributes
a_orb1 = (rp_orb1+ra_orb1)/2;
e_orb1 = (ra_orb1-rp_orb1)/(ra_orb1+rp_orb1);
h_orb1 = sqrt(rp_orb1 * mu * (1 + e_orb1));
T_orb1 = (2*pi*a_orb1^(3/2))/sqrt(mu);
%
% Initial Positions of Spacecrafts
rB1 = (((h_orb1^2)/mu)*(1/(1+e_orb1*cosd(Btheta))))*[cosd(Btheta) sind(Btheta) 0]';
rC1 = (((h_orb1^2)/mu)*(1/(1+e_orb1*cosd(Ctheta))))*[cosd(Ctheta) sind(Ctheta) 0]';
%
% Initial Velcities
vB1 = (mu/h_orb1)*[-sind(Btheta) e_orb1+cosd(Btheta) 0]';
vC1 = (mu/h_orb1)*[-sind(Ctheta) e_orb1+cosd(Ctheta) 0]';
%
% Moving C to C' solving Eccentric anomaly
Ec = 2*atan(sqrt((1-e_orb1)/(1+e_orb1))*tand(Ctheta/2));
%
% Keplers Equation
tC = (T_orb1/(2*pi))*(Ec-e_orb1*sin(Ec));

delta_timRang = [3600:600:7200]; %time range in sec. 1-2 hrs by 10 min intervals
% time to reach C'
tC_p = tC + delta_timRang;
%
% Determine Ec' from Mean anomaly
MeC_p = (2*pi)*(tC_p./T_orb1);

for i = 1:length(MeC_p)
   Ec_p(i) = eccentricEq(e_orb1,MeC_p(i));
   % function attatched
end
% solve mean anomaly of C' location
CpTheta = 360 - abs(2*atand(sqrt((1+e_orb1)/(1-e_orb1))*tan(Ec_p./2)));

% Position and Velocity vector for C'
for i = 1:length(MeC_p)
rC_p = (((h_orb1^2)/mu)*(1/(1+e_orb1*cosd(CpTheta(i)))))*[cosd(CpTheta(i)) sind(CpTheta(i)) 0]';
[vB2(:,i),vC_p(:,i)] = lambert_eq(rB1,rC_p,delta_timRang(1),'pro')
end

