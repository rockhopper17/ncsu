close all; clear all; clc;

figure;

%d=load('data/Step23');
%d=load('data/P_Run1');
%d=load('data/P_Run2');
%d=load('data/P_Run3');
%d=load('data/P_Run4');
%d=load('data/PI_Run1');
%d=load('data/PI_Run2');
%d=load('data/PID_Run1');
%d=load('data/PID_Run2');
%d=load('data/PID_Run3');
d=load('data/PID_Run4');

plot(d(:,1),d(:,2),'b-','DisplayName','Process variable');
hold on; grid on;
plot(d(:,1),d(:,3),'r-','DisplayName','Set point');
ylabel('amplitude');
xlabel('time (s)');
set(gca,'FontSize',16);
legend('location','northeast');

%xlim([211 inf]); % step23
%xlim([2.5 4]); % p_run1
%xlim([3.5 5]); % p_run2
%xlim([1.75 3.4]); % p_run3
%xlim([2 4.5]); % p_run4
%xlim([1.8 3.8]); % pi_run2
%xlim([6 8.5]); % pid_run1
%xlim([5 9.5]); % pid_run2
%xlim([2.8 8]); % pid_run3
xlim([2.75 3.5]); % pid_run4
