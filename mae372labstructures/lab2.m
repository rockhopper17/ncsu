% intro circuits lab

% clear all vars and plots
close all; clear all; clc;

% potentiomater experiment
x = [0.0036 0.64 2.1 4.0 6.2 8.9];	% resistance
y = [0.062 0.64 2.0 4.0 6.2 9.0];	% voltage

% get least squares fit and R^2 value
p = polyfit(x,y,1);
yfit = polyval(p,x);
yresid = y - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1) * var(y);
rsq = 1 - SSresid/SStotal;

% plot voltage vs resistance with least squares fit
fig = figure(1);
colormap(jet);  % macOS has different default, want jet
hold on;
grid on;
title('Potentiometer Experiment 2: Voltage vs Resistance');
%xlim([0 6.0]);
%ylim([168 192]);
xlabel('Resistance (k\Omega)');
ylabel('Voltage (V)');

plot(x,y,'ok');

% plot regression fit
xl = xlim;
x1 = linspace(xl(1),xl(2));
y1 = polyval(p,x1);
plot(x1,y1,'b');

%******************************************************
% low pass filter experiment

% setup x and y vals for plotting
x = [200 500 1000 1500 2000 4000 5000 10000];	% frequency (Hz)
y = [9.60 7.68 5.00 3.60 2.78 1.50 1.18 0.60];	% voltage / amplitude

H = tf(x,y);	% transfer function for Bode plot

% bode plot for CH2 voltage vs frequency
fig = figure(2);
colormap(jet);  % macOS has different default, want jet
hold on;
grid on;
title('Low-Pass Filter Experiment 3: Bode Plot of CH2 Voltage vs Frequency');
%xlim([0 6.0]);
%ylim([168 192]);
%xlabel('Resistance (k\Omega)');
%ylabel('Voltage (V)');

h = bodeplot(H);
setoptions(h,'FreqUnits','Hz');

fig = figure(3);
plot(x,y);
title('Voltage vs Frequency');
xlabel('Frequency (Hz)');
ylabel('Voltage / CH2 Amplitude (V)');
