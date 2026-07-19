% lab 7 - reinforced fiberglass composite fabrication and 4-point beam testing

% clear all vars and plots
close all; clear all; clc;

a = 1.534 * .193;  % area = width x thickness

loaddata = [3.7 11.3 15.9 19.2 21.8 24.5 27.4 30.1 32.4 47.4];
straindata = [157 1547 2285 3042 3426 3812 4562 5233 5863 5876]; 

stressdata = loaddata / a;

% plot stress vs strain
figure;
colormap(jet); 
hold on;
grid on;
title('Stress-Strain curve for Reinforced Fiberglass Composite');
%xlim([0.0045 0.0065]);
%ylim([168 192]);
xlabel('Strain (-\mu\epsilon)');
ylabel('Stress (-psi)');

plot(straindata,stressdata,'.-k','MarkerSize',10);

