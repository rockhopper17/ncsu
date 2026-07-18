close all; clear all; clc;

d = readmatrix(['finalprojdata/evodata_tg_Re10.txt']);
t = d(:,1);
veldiv10 = d(:,2);
kindec10 = d(:,3);
d = readmatrix(['finalprojdata/evodata_tg_Re100.txt']);
veldiv100 = d(:,2);
kindec100 = d(:,3);
d = readmatrix(['finalprojdata/evodata_tg_Re1000.txt']);
veldiv1000 = d(:,2);
kindec1000 = d(:,3);

fkin10 = 0.25*exp(-4*.1*t);
fkin100 = 0.25*exp(-4*.01*t);
fkin1000 = 0.25*exp(-4*.001*t);

plot(t,kindec10,'k-','DisplayName','Re=10 (numeric)');
hold on; grid on;
plot(t,fkin10,'k--','DisplayName','Re=10 (analytic)');
plot(t,kindec100,'b-','DisplayName','Re=100 (numeric)');
plot(t,fkin100,'b--','DisplayName','Re=100 (analytic)');
plot(t,kindec1000,'r-','DisplayName','Re=1000 (numeric)');
plot(t,fkin1000,'r--','DisplayName','Re=1000 (analytic)');
xlabel('time (s)');
ylabel('total kinetic energy');
ylim([0 0.3]);
set(gca,'FontSize',16);
legend('location','southwest');

figure;
plot(t,veldiv10,'k-','DisplayName','Re=10');
hold on; grid on;
plot(t,veldiv100,'b-','DisplayName','Re=100');
plot(t,veldiv1000,'r-','DisplayName','Re=1000');
xlabel('time (s)');
ylabel('velocity divergence');
%ylim([0 0.3]);
set(gca,'FontSize',16);
legend('location','southwest');

