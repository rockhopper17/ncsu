% Andrew Navratil
% MAE 458 Propulsion Fall 2019
% Exam 1
% Due 2019-10-07

% clear all vars and plots
close all; clear all; clc;

% givens
M0 = 0.8; % flight mach num
T04 = 1667; % turbine inlet temp [K]
hR = 42798.4; % fuel heating value [kJ/kg]
pf = 3; % turbofan fan total pressure ratio

% lookup constants using Anderson - Fundamentals of Aerodynamicsd 5th ed
% using geometric altitude above mean sea level (hG) in appendix D
%   at 25000 ft = 7620 m (using values at hG = 7600m)
T0 = 238.82; % temp [K]

gamma = 1.4; % ratio of specific heats, assume calorically perfect gas
cp = 1004; % spec heat const pressure

% freestream conditions
a0 = sqrt((gamma-1)*cp*T0); % speed of sound
v0 = M0*a0; % velocity

% choice of engine is where values are closest to
% max specific thrust and min fuel consumption

% theta r and theta lambda
tr = 1 + ((gamma-1)/2)*M0^2; % temp ratio freestream (theta r)
tl = T04/T0; % ratio burner exit enthalpy to ambient enthalpy (theta lambda)

% compressor ratios
pc = 4:0.1:100; % pressure ratio
%pc = 1:30; % pressure ratio
tc = pc.^((gamma-1)/gamma); % temp ratio

f = (cp*T0/(hR*1e-3)) * (tl - tr*tc); % fuel-air mass ratio
efft = 1 - 1./(tr*tc); % thermal efficiency

% turbojet
tt = 1 - (tr/tl)*(tc-1); % temp ratio turbine (turbojet)
v9a0 = sqrt( (2/(gamma-1)) * (tl./(tr*tc)) .* (tr*tc.*tt - 1) ); % vel ratio
spttj = a0 * (v9a0 - M0); % specific thrust
tsfctj = f./spttj; % TSFC (thrust specific fuel consumption)
effptj = 2*M0./(v9a0+M0); % propulsive efficiency
efftj = efft.*effptj; % overall efficiency

tctjopt = sqrt(tl) / tr; % optimum compressor temp ratio
pctjopt = tctjopt^(gamma/(gamma-1)) % optimum compressor pressure ratio
%sptopt = a0 * ( sqrt( (2/(gamma-1)) * ( (sqrt(tl)-1)^2 + tr - 1) ) - M0);
%fopt = (cp * T0 / (hR*1000)) * (tl - sqrt(tl));
%tsfcopt = fopt/sptopt;

% turbofan
tf = pf^((gamma-1)/gamma); % temp ratio fan (turbofan)
%alpha = 5; % why is this giving greater propulsive efficiency??
alpha = (1/(tr*(tf-1))) * ( (tl-tr*(tc-1)-tl./(tr*tc))...
	- 0.25*( sqrt((tr*tf-1)/(tr-1)) + 1)^2); % optimal bypass ratio at each tc
alpha(alpha<0.001) = 0.001;
v9a0 = sqrt( (2/(gamma-1)) * ( tl - tr.*(tc - 1 + alpha*(tf-1)) - (tl./(tr*tc)) ) );
v19a0 = sqrt( (2/(gamma-1)) * (tr*tf - 1));
spttf = a0 * (1./(1+alpha)) .* (v9a0 - M0 + alpha.*(v19a0 - M0));
tsfctf = f./((1+alpha).*spttf);
effptf = 2*M0*(v9a0-M0+alpha*(v19a0-M0))./(v9a0.^2-M0^2+alpha*(v19a0^2-M0^2));
efftf = efft.*effptf;

alpha = 5; % why is this giving greater propulsive efficiency??
v9a0 = sqrt( (2/(gamma-1)) * ( tl - tr.*(tc - 1 + alpha*(tf-1)) - (tl./(tr*tc)) ) );
v19a0 = sqrt( (2/(gamma-1)) * (tr*tf - 1));
spttf2 = a0 * (1./(1+alpha)) .* (v9a0 - M0 + alpha.*(v19a0 - M0));
tsfctf2 = f./((1+alpha).*spttf2);
effptf2 = 2*M0*(v9a0-M0+alpha*(v19a0-M0))./(v9a0.^2-M0^2+alpha*(v19a0^2-M0^2));
efftf2 = efft.*effptf2;


% turboprop
effprop = 0.5; % assume ideal propellar efficiency
%Mattingly book had error for tt*: should be 1/tr*tc not tl/tr*tc
tt = (1./(tr*tc)) + (((gamma-1)/2)*M0^2)/(tl*effprop^2); % optimal turbine temp
tth = 1 - (tr/tl)*(tc-1); % high pressure turbine temp ratio
ttl = tt./tth; % low pressure turbine temp ratio
v9a0 = sqrt( (2/(gamma-1)) * (tl*tt - (tl./(tr*tc))) );
cc = (gamma-1)*M0*(v9a0-M0); % core stream work coefficient
cprop = effprop*tl*tth.*(1-ttl); % prop work coefficient
ctot = cc+cprop; % total work coefficient
spttp = (ctot*cp*T0)/(M0*a0);
tsfctp = f./spttp;
efftp = ctot./(tl-tr*tc);
effptp = efftp./efft;

% plot
figure;
yyaxis left;
plot(pc,spttj,'DisplayName','Turbojet','LineWidth',2);
hold on;
plot(pc,spttf,'DisplayName','Turbofan','LineWidth',2);
plot(pc,spttf2,'DisplayName','Turbofan2','LineWidth',2);
%plot(pc,spttp,'DisplayName','Turboprop','LineWidth',2);
plot(pctjopt,spttj(find(abs(pc-round(pctjopt,1))<1e-6)),'*','LineWidth',2);
%ylim([0 inf]); % ignore the negative values at low tc
ylabel('Specific Thrust [N/(kg/sec)]');
xlabel('\pi_{c}');
yyaxis right;
plot(pc,tsfctj,'DisplayName','Turbojet','LineWidth',2);
plot(pc,tsfctf,'DisplayName','Turbofan','LineWidth',2);
plot(pc,tsfctf2,'DisplayName','Turbofan2','LineWidth',2);
%plot(pc,tsfctp,'DisplayName','Turboprop','LineWidth',2);
plot(pctjopt,tsfctj(find(abs(pc-round(pctjopt,1))<1e-6)),'*','LineWidth',2);
%ylim([0 inf]);
ylabel('TSFC [mg/(N*sec)]');
legend('location','northeast');

figure;
yyaxis left;
plot(pc,efftj*100,'DisplayName','Turbojet','LineWidth',2);
hold on;
plot(pc,efftf*100,'DisplayName','Turbofan','LineWidth',2);
%plot(pc,efftf2*100,'DisplayName','Turbofan2','LineWidth',2);
%plot(pc,efftp*100,'DisplayName','Turboprop','LineWidth',2);
ylabel('\eta_{O}');
xlabel('\pi_{c}');
yyaxis right;
plot(pc,effptj*100,'DisplayName','Turbojet','LineWidth',2);
plot(pc,effptf*100,'DisplayName','Turbofan','LineWidth',2);
%plot(pc,effptf2*100,'DisplayName','Turbofan2','LineWidth',2);
%plot(pc,effptp*100,'DisplayName','Turboprop','LineWidth',2);
ylabel('\eta_{P}');
legend('location','southeast');

figure;
plot(pc,alpha);
ylabel('optimum bypass ratio');
xlabel('\pi_{c}');

