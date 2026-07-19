% cantilever beam stress strain lab 3

% clear all vars and plots
close all; clear all; clc;

% potentiomater experiment
x = [3 6 9];	% location / dist
y = [124 265 415];	% strain gage values in micro strains

% get least squares fit and R^2 value
p = x(:)\y(:);			% calculate slope to force origin intercept
%p = polyfit(x,y,1);
%yfit = polyval(p,x);
yfit = p*x;				% calculate y values using slope instead of polyfit
yresid = y - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1) * var(y);
rsq = 1 - SSresid/SStotal;

% plot strain vs distance with least squares fit
fig = figure(1);
colormap(jet);  
hold on;
grid on;
title('Cantilever Beam Stress-Strain Lab 3: Strain vs Distance');
xlim([0 10]);
ylim([0 500]);
xlabel('x (in)');
ylabel('strain (\mu\epsilon)');

plot(x,y,'ok');

% plot regression fit
xl = xlim;
x1 = linspace(xl(1),xl(2));
y1 = polyval([p 0],x1);
plot(x1,y1,'-b');


