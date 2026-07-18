% ignition delay plot
% stochiometric C2H4/O2/N2 mixture at T=1500K, P=2500 Pa
% using matlab cantera examples: ignite.m, reactor2.m
% and a bit from a python example: batch_reactor_ignition_delay_NTC.ipynb
close all; clear all; clc;

% need to use xml file (cti file load giving error on new Mac M1 matlab)
gas = Solution('ffcmy9reduced30.xml','gas');
%gas = GRI30;

% set given temp and pressure
%set(gas,'T',1500.0,'P',2500.0);

% set equivalence ratio for ethylene
phi = 1.0;
a = 3.0; % c2h4 + 3(o2 + 3.76 n2) -> 2 co2 + 2 h2o + 11.28 n2
nsp = nSpecies(gas);

% find ethylene, nitrogen, and oxygen indices
ic2h4 = speciesIndex(gas,'C2H4');
io2  = speciesIndex(gas,'O2');
in2  = speciesIndex(gas,'N2');

% set mole fractions
x = zeros(nsp,1);
x(ic2h4,1) = phi;
x(io2,1) = a;
x(in2,1) = 3.76 * a;
set(gas,'T',1500.0,'P',2500.0,'X',x);
%set(gas,'X',x);

% create a reactor, and insert the gas
%r = IdealGasReactor(gas);
r = ConstPressureReactor(gas);

% create a reactor network and insert the reactor
network = ReactorNet({r});

% perform time integration
t = 0;
dt = 2.0e-7; % time step in sec (Edwards)
%dt = 1.0e-5; % time step in sec
%runtime = 0.05; % time to run reaction in sec
runtime = 0.005; % time to run reaction in sec
t0 = cputime;
for n = 1:runtime/dt
  t = t + dt;
  advance(network, t);
  tim(n) = time(network);
  temp(n) = temperature(r);
  press(n) = pressure(r);
  %xprod(n,1:3) = moleFraction(gas,{'CO2','H2O','N2'});
  xigdelay(n,1) = massFraction(gas,{'OH'});
end
disp(['CPU time = ' num2str(cputime - t0)]);

% find ignition delay time from max mass fraction of OH
% looks for first occurrence of rounded value, as concentration continues to inc
maxoh = round(max(xigdelay),4);
idxmaxoh =find(xigdelay >= maxoh,1);

figure(1);
plot(tim,temp,'k-');
hold on;
plot(tim(idxmaxoh),temp(idxmaxoh),'ro','MarkerSize',10);
title('Ethylene-Air Stoichiometric Ignition Delay: Const Press Reactor');
xlabel('Time (s)');
ylabel('Temperature (K)');
ax = gca;
ax.FontSize = 18;
ax.XAxis.Exponent = 0;
%set(gca,'FontSize',18);

%clf;
%subplot(2,2,1);
%plot(tim,temp);
%xlabel('Time (s)');
%ylabel('Temperature (K)');
%subplot(2,2,2)
%plot(tim,xprod(:,1));
%xlabel('Time (s)');
%ylabel('CO2 Mole Fraction (K)');
%subplot(2,2,3)
%plot(tim,xprod(:,2));
%xlabel('Time (s)');
%ylabel('H2O Mole Fraction (K)');
%subplot(2,2,4)
%plot(tim,xprod(:,3));
%xlabel('Time (s)');
%ylabel('N2 Mole Fraction (K)');
%clear all
%cleanup

