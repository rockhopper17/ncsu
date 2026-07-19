% Name: Andrew Navratil
% Date: 2017-09-08
% Lab Section #205
% Project 1: Engine Control Unit Analysis
% Description: Write code to analyze and visualize information captured by the engine control unit
%              of a high performance vehicle.

clc; clear; close('all');

%% Import Data
% prompt user for name of file for importing data
datafile = input ('Input the name of the data file you would like to analyze: ', 's');
% for testing
%datafile = 'test01.csv';

% import the data, a csv file is expected
% skip the first two header rows, just pull in the numeric data starting in third row
% note: csvread row and col are zero-based
data = csvread(datafile, 2, 0);

%% Analyze Data and print info to the command window

%format short;

% pull columns out of data for improved code readability and hopefully performance when accessed multiple times
dataTime = data(:,1);
dataRPM = data(:,2);
dataFuelFlow = data(:,3);
dataCoolantTemp = data(:,4);
dataBattery = data(:,5);
dataOilPressure = data(:,6);
dataFuelPressure = data(:,7);
dataPedalPosition = data(:,8);

% get max RPM and time of occurrence
[maxRPM, idx] = max(dataRPM);
maxRPMTime = data(idx);

% get max coolant and time of occurrence
[maxCoolantTemp, idx] = max(dataCoolantTemp);
maxCoolantTempTime = data(idx);

% get duration of entire test in minutes
duration = (max(dataTime) / 60);

% get average battery voltage
avgBattery = mean(dataBattery);

% get min oil temp and time of occurrence
[minOilPressure, idx] = min(dataOilPressure);
minOilPressureTime = data(idx);

% get average coolant temp
avgCoolantTemp = mean(dataCoolantTemp);

% print the analysis to the command window
fprintf('\nThe maximum RPM was %.4f, and it occurred at %.2f seconds.\n', maxRPM, maxRPMTime)
fprintf('The maximum coolant temperature was %.4f degrees Fahrenheit, and it occurred at %.2f seconds.\n', maxCoolantTemp, maxCoolantTempTime)
fprintf('The duration for the test was %.2f minutes.\n', duration)
fprintf('The average battery voltage was %.4f volts.\n', avgBattery)
fprintf('The minimum oil pressure was %.4f psi, and it occurred at %.2f seconds.\n', minOilPressure, minOilPressureTime)
fprintf('The average coolant temperature was %.4f degrees Fahrenheit.\n', avgCoolantTemp)

%% Calculations

% calculate raw pedal position from the sensor values give in percentages
rawPedalPos = round(1024 * (dataPedalPosition ./ 100));

% calculate the coolant temperature in Celsius from the sensor values given in Fahrenheit
coolantTempCelsius = ( (dataCoolantTemp - 32) .* (5/9) );

% setup variables related to times for reuse in multiple plots
timeLabel = 'Time (sec)';
timelimits = [min(dataTime), max(dataTime)];

%% Plot: figure 1

% plot RPM vs time and raw pedal position vs time in figure 1, utilizing yyaxis
figure(1);

grid on;
title('RPM and Throttle vs. Time');
xlabel('Time (sec)');

yyaxis left;
plot(dataTime, dataRPM);
ylabel('RPM');
xlim(timelimits);
ylim([min(dataRPM), max(dataRPM)]);

yyaxis right;
plot(dataTime, rawPedalPos);
ylabel('PPS Raw');
xlim(timelimits);
ylim([min(rawPedalPos), max(rawPedalPos)]);

%[ax, h1, h2] = plotyy(dataTime, dataRPM, dataTime, rawPedalPos);

%set(get(ax(1), 'YLabel'), 'String', 'RPM');
%set(ax(1), 'YLim', [min(dataRPM), max(dataRPM)]);
%set(get(ax(2), 'YLabel'), 'String', 'PPS Raw');
%set(ax(2), 'YLim', [min(rawPedalPos), max(rawPedalPos)]);

%yyaxis left;
%ylabel('RPM');
%ylim([min(dataRPM), max(dataRPM)]);
%yyaxis right;
%ylabel('PPS Raw');

%% Plot: figure 2

% plot 4 graphs together (subplots) as shown by figure 2
figure(2);

% initialize a variable for use in creating the mean lines
onesarr = ones(size(dataTime));

% subplot 1: green plot of coolant temperature (celsius) vs time
subplot(2,2,1);
grid on;
title('Coolant Temperature vs. Time');
xlabel(timeLabel);
ylabel('Coolant Temperature (^oC)');

hold on;  % use this to plot multiple lines on same graph
plot(dataTime, coolantTempCelsius, 'g');
plot(dataTime, onesarr * mean(coolantTempCelsius), 'r');
xlim(timelimits);
ylim([min(coolantTempCelsius), max(coolantTempCelsius)]);

% subplot 2: magenta plot of oil pressure vs time
subplot(2,2,2);
grid on;
title('Oil Pressure vs. Time');
xlabel(timeLabel);
ylabel('Oil Pressure (psi)');

hold on;
plot(dataTime, dataOilPressure, 'm');
plot(dataTime, onesarr * mean(dataOilPressure), 'r');
xlim(timelimits);
ylim([min(dataOilPressure), max(dataOilPressure)]);

% subplot 3: cyan plot of battery pressure vs time
subplot(2,2,3);
grid on;
title('Battery Voltage vs. Time');
xlabel(timeLabel);
ylabel('Battery Voltage (volts)');

hold on;
plot(dataTime, dataBattery, 'c');
plot(dataTime, onesarr * mean(dataBattery), 'r');
xlim(timelimits);
ylim([min(dataBattery), max(dataBattery)]);

% subplot 4: black plot of fuel pressure vs time
subplot(2,2,4);
grid on;
title('Fuel Pressure vs. Time');
xlabel(timeLabel);
ylabel('Fuel Pressure (psi)');

hold on;
plot(dataTime, dataFuelPressure, 'k');
plot(dataTime, onesarr * mean(dataFuelPressure), 'r');
xlim(timelimits);
ylim([min(dataFuelPressure), max(dataFuelPressure)]);

%% Plot: figure 3

% plot a red bar graph for three values of throttle, as shown by figure 3
figure(3);

% get number of data points where pedal was idle, full, or in between
numIdle = sum(dataPedalPosition <= 5);
numFull = sum(dataPedalPosition >= 95);
numInBetween = sum(dataPedalPosition > 5 & dataPedalPosition < 95);

% create bar graph
bar([numIdle,numInBetween, numFull], 'r');
grid on;
title('Pedal Position Bar Graph');
ylabel('Number of Data Points');
set(gca, 'XTickLabel', {'Idle', 'InBetween', 'Full'});
ylim([0, max([numIdle, numFull, numInBetween])]);
% no xlim to set for bar graph


