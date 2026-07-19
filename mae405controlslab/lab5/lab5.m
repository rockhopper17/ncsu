close all; clear all; clc;

% experimental data
d=load('lab5_part2.lvm');
t2 = d(:,1);
data2 = d(:,2);

% theoretical data
V1=15;
R1=300e3;
R2=300e3;
R3=100e3;
C1=100e-6;
C2=10e-6;
tau = (R1*R2*C1)/(R1+R2);

tdiff=0:0.1:100;
Vdiff = (-R2*R3*C2)*V1*exp(-tdiff./tau)/(tau*(R1+R2));

figure;
plot(t2(2:end)-t2(2),data2(2:end),'DisplayName','Experimental');
hold on;grid on;
plot(tdiff,Vdiff,'DisplayName','Theoretical','LineWidth',2);
ylabel('V_{out} (V)');
xlabel('time (s)');
set(gca,'FontSize',16);
legend('location','southeast');
title('Differentiated Circuit');

