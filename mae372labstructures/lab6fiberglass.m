% lab 6 - fiberglass composite fabrication and tensile testing

% clear all vars and plots
close all; clear all; clc;

% potentiomater experiment
%d90 = [.0116 .0144 .0173 .0207 .0236 .0260 .0289 .0322 .0345 .0369 .0393 .0417 .0441 .0464 .0489 .0512 .0536 .0560 .0584 .0608 .0636 .0665[;
l90 = [9.6 11 20 34.1 43.9 50.9 59.7 71.5 80.5 89.9 98.4 107.3 116.1 124.5 132.4 141 148.8 155.9 163.3 164.7 169.6 176.6];
e90 = [2179 2203 2579 3568 4077 4705 5308 5999 6566 7400 7955 8520 9349 9894 10436 11518 12044 12570 13348 13598 14074 14677];

%d45 = [56 77 107 126 150 178 197 221 250 269 298 327 356 377 405 428 452 477 501 525 550 578 602] * 1e-4;
l45 = [2 6.5 10.1 11 11.6 12 13.8 16.3 21 23.6 26.5 28.9 32.1 33.6 35.5 36.4 38.3 39.2 40.9 41.9 43.1 44.4 45];
e45 = [1837 2860 3547 3948 4325 4382 4671 5782 6746 8549 9883 11944 14074 15578 17029 19143 20531 22624 24095 26274 28411 29803 31921];

s90 = l90 / (.738 * .009);
s45 = l45 / (.712 * .01);

% plot for 90deg
figure;
colormap(jet); 
hold on;
grid on;
title('Stress-Strain curve for 201-1-90');
%xlim([0.0045 0.0065]);
%ylim([168 192]);
xlabel('Strain (\mu\epsilon)');
ylabel('Stress (psi)');

plot(e90,s90,'.-k','MarkerSize',10);

% plot for 45deg
figure;
colormap(jet); 
hold on;
grid on;
title('Stress-Strain curve for 201-1-45');
%xlim([0.0045 0.0065]);
%ylim([168 192]);
xlabel('Strain (\mu\epsilon)');
ylabel('Stress (psi)');

plot(e45,s45,'.-k','MarkerSize',10);
