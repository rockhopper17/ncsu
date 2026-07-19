% lab 4 - pressure vessel (sprite can) strain

% clear all vars and plots
close all; clear all; clc;

% potentiomater experiment
x = [0.005 0.006 0.005 0.005 0.006];	% thickenss
y = [-35.3 -72.5 -39.8 -40.4 -73.0];	% pressure
err = [35.3*.04*.5 72.5*.0712*.5 39.8*.045*.5 40.4*.0455*.5 73.0*.0717*.5];

% get least squares fit and R^2 value
p = polyfit(x,y,1);
yfit = polyval(p,x);
yresid = y - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1) * var(y);
rsq = 1 - SSresid/SStotal;

% plot pressure vs thickness
fig = figure(1);
colormap(jet); 
hold on;
grid on;
title('Lab 4 Pressure Vessel: Pressure vs. Wall Thickness');
xlim([0.0045 0.0065]);
%ylim([168 192]);
xlabel('Wall Thickness (in)');
ylabel('Pressure (psi)');

plot(x,y,'.k','MarkerSize',10);
errorbar(x,y,err,'LineStyle','none');

% plot regression fit
xl = xlim;
x1 = linspace(xl(1),xl(2));
y1 = polyval(p,x1);
plot(x1,y1,'b');

