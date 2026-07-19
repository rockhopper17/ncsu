% clear all vars and plots
close all; clear all; clc;

% B(i) plot Cm vs CL
CL = -1.5:0.1:1.5;
m = -0.1;

Cm0 = 0.012;
Cm = m*CL + Cm0;

plot(CL,Cm);
grid on;
ylabel('C_m');
xlabel('C_L');
set(gca,'FontSize',14);

% B(ii) plot Cm vs CL for +10,-10,0
CL = -5.0:0.1:5.0;
Cm = m*CL + Cm0;
Cmde = -0.035;
Cm0a = Cm0 + 10*Cmde;
Cm0b = Cm0 - 10*Cmde;
Cma = m*CL + Cm0a;
Cmb = m*CL + Cm0b;

figure;
plot(CL,Cm,'DisplayName','$\delta_e = 0^{\circ}$');
grid on; hold on;
plot(CL,Cma,'DisplayName','$\delta_e = +10^{\circ}$');
plot(CL,Cmb,'DisplayName','$\delta_e = -10^{\circ}$');
ylabel('C_m');
xlabel('C_L');
hl = legend('location','northeast');
set(hl,'Interpreter','latex');
set(gca,'FontSize',14);

% B(ii) plot de vs CL
m = (10-0)/(-3.38 - 0.12);
b = 3.38*m + 10;
y = m*CL + b;

figure;
plot([3.62 0.12 -3.38],[-10 0 10],'.b','MarkerSize',20);
grid on; hold on;
plot(CL,y,'-b');
ylim([-12 12]);
ylabel('\delta_{e,trim} (deg)');
xlabel('C_{L,trim}');
set(gca,'FontSize',14);

% B(ii) plot de vs CL for forward CG
figure;
plot([0 1.5],[0.34 -25],'.-b','MarkerSize',20);
grid on; hold on;
ylim([-30 2]);
xlim([0 2.0]);
ylabel('\delta_{e,trim} (deg)');
xlabel('C_{L,trim}');
set(gca,'FontSize',14);

