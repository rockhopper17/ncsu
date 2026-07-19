% clear all vars and plots
close all; clear all; clc;

rho = 1.23; % [kg/m^3]
v = 1.0; % [m/s]
S = 0.064; % [m^2]
c = 0.08; % [m]

Q = 0.5*rho*v*v;

alpha = [-2.0:1.0:5.0]'
Lw = [-0.000016 0.003328 0.006671 0.010011 0.013345 0.016672 0.019990 0.023297]'
Lt = [-0.000484 -0.000162 0.000161 0.000484 0.000806 0.001127 0.001446 0.001764]'

L = Lw + Lt
CL = L/(Q*S)

d1 = 0.132; % forward CG [m]
Mcg1 = Lw*(d1-0.12) - Lt*(0.51-d1)
CMcg1 = 0.00666*(d1-0.12)/c + (L*(d1-0.12)-0.39*Lt)/(Q*S*c)

d2 = 0.14; % aft CG [m]
Mcg2 = Lw*(d2-0.12) - Lt*(0.51-d2)
CMcg2 = 0.00666*(d2-0.12)/c + (L*(d2-0.12)-0.39*Lt)/(Q*S*c)

figure(1)
ph(1)=plot(alpha,CMcg1,'b-','DisplayName','Forward CG');
hold on
ph(2)=plot(alpha,CMcg2,'b--','DisplayName','Aft CG');
ylabel('C_{Mcg}')
xlabel('\alpha_{FRL}')
title('C_{Mcg} vs \alpha_{FRL}')
yline(0);
xline(0);
grid on
legend(ph,'location','northeast')
set(gca,'FontSize',14);

figure(2)
ph2(1)=plot(CL,CMcg1,'b-','DisplayName','Forward CG');
hold on
ph2(2)=plot(CL,CMcg2,'b--','DisplayName','Aft CG');
ylabel('C_{Mcg}')
xlabel('C_{L}')
title('C_{Mcg} vs C_{L}')
yline(0);
xline(0);
grid on
legend(ph2,'location','northeast')
set(gca,'FontSize',14);

figure(3)
ph3(1)=plot(alpha,CL,'b-','DisplayName','Forward and Aft CG');
hold on
ylabel('C_{L}')
xlabel('\alpha_{FRL}')
title('C_{L} vs \alpha_{FRL}')
yline(0);
xline(0);
grid on
legend(ph3,'location','northeast')
set(gca,'FontSize',14);

