% clear all vars and plots
close all; clear all; clc;

% givens
M0 = 0.9; % flight mach num
T04 = 1477; % turbine inlet temp [K]
hR = 43.124e6; % fuel heating value [J/kg]
thrust = 88964; % thrust 20000 lbf to N

effd = 0.97; % diffuser efficiency
effc = 0.85; % compressor efficiency
effb = 0.98; % burner efficiency
efft = 0.90; % turbine efficiency
effn = 0.98; % nozzle efficiency

pb = 0.98; % burner pressure ratio
pf = 3; % turbofan fan total pressure ratio

% lookup constants using Anderson - Fundamentals of Aerodynamicsd 5th ed
% using geometric altitude above mean sea level (hG) in appendix D
%   at 35000 ft = 10668 m (using values at hG = 10700m)
T0 = 218.73; % temp [K]
P0 = 23790; % pressure [N/m^2]
rho = 0.37892; % density [kg/m^3]

gamma = 1.4; % ratio of specific heats
cp = 1004; % spec heat const pressure [J/kg K]

% freestream conditions
a0 = sqrt((gamma-1)*cp*T0); % speed of sound

% theta r and theta lambda
tr = 1 + ((gamma-1)/2)*M0^2; % temp ratio freestream (theta r)
tl = T04/T0; % ratio burner exit enthalpy to ambient enthalpy (theta lambda)

% compressor optimum
tc = sqrt(tl) / tr % optimum compressor temp ratio
pc = tc^(gamma/(gamma-1)) % optimum compressor pressure ratio
tt = 1 - (tr/tl)*(tc-1) % temp ratio turbine (turbojet)
pt = tt^(gamma/(gamma-1)) % turbine pressure ratio

tf = pf.^((gamma-1)/gamma); % temp ratio fan (turbofan)
alpha = (1./(tr.*(tf-1))) .* ( tl - tr.*(tc-1) - tl./(tr.*tc)...
				- 0.25*( sqrt((tr.*tf-1)) + sqrt(tr-1)).^2) % optimum bypass ratio
% overall
v9a0 = sqrt( (2/(gamma-1)) * (tl/(tr*tc)) * (tr*tc*tt - 1) ); % vel ratio
spt = a0 * (v9a0 - M0) % specific thrust
mdot = thrust/spt % mass flow rate
inarea = mdot/(rho*(v9a0*a0)) % outlet area

% compressor inlet and outlet
T02 = T0*tr
T03 = T02*(1+(1/effc)*(pc^((gamma-1)/gamma) - 1))

P02 = P0*(1+effd*(T02/T0 - 1))^(gamma/(gamma-1))
P03 = P02*pc

% burner fuel-air ratio
%f = ((T04/T03) - 1) / (hR/(cp*T03) - (T04/T03))

% turbine inlet and outlet
%mdotf = 0;
%T05 =  (mdot + mdotf)*T04 - 1.15*mdot*(T03-T02)
T05 = T04*tt

%P04 = P03*pb
%P05 = P04*(1-(1/efft)*(1-T05/T04))^(gamma/(gamma-1))

%mdott = 1.15*mdot*(T03 - T02)/(T04-T05)
cpowout = mdot*cp*(T03 - T02) % turbine power output = comp pow req
%tpowout = mdott*cp*(T04 - T05) % turbine power output = comp pow req
tpowout = mdot*cp*(T04 - T05) % turbine power output = comp pow req
f = (cp*T0/hR) * (tl - tr*tc) % fuel-air mass ratio
tsfc = f/spt % TSFC (thrust specific fuel consumption)

% efficiency
effpropulsive = 2*M0/(v9a0+M0) % propulsive efficiency
effthermal = 1 - 1/(tr*tc) % thermal efficiency
efftotal = effthermal*effpropulsive % overall efficiency

