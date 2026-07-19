% Name Andrew Navratil
% Date 2017-08-31
% Section #205
% In-Lab 2

clear all; close all; clc % clear functions
%% Instructor-Guided Portion
%% Problem 1 - Sensor Data - Summer 2015, Updated Fall 2017
% Download Sensor_data.xlsx from Moodle. 

% Import the data set using xlsread():
[sensorData,~,~] = xlsread('Sensor_data.xlsx');  % grabs numberic values

% a. Find the mean value for each sensor:
meanVals = mean(data(:,2:end));  % index into sensor data to get mean

% b. Find the maximum value recorded for each sensor and the time:
[maxVal,maxIndex] = max(data(:,2:end));  % indexes row
times = sensorData(:,1);  % set all times to a variable
maxTimes = times(maxIndex); % uses index to extract actual max

% c. Co-plot the sensor results:
x = times;
figure(1);
plot(x,sensorData(:,2:end));  % can separate out x,y plots if need to format
% formatting
grid on;
title('Sensor Data');
xlabel('Time (s)');
ylabel('Temperature (^oC)');

%% Problem 2 - Input/Output - Spring 2016
% Prompt the user for their name (a string):
name = input('Please type your name: ','s');

% Prompt the user for an x value (in radians):
x = input('Input a value for x (in radians): ');

% a. Compute the sine, cosine, and tangent values of the input x:
xSin = sin(x);
xCos = cos(x);
xTan = tan(x);

% b. Use disp() and fprintf() to print results to the command window:
disp([name ', your calculations are complete!']);
fprintf('Sine of %.2f is %.2f.\n', x, xSin);
fprintf('Cosine of %.2f is %.2f.\n', x, xCos);
fprintf('Tangent of %.2f is %.2f.\n', x, xTan);

%% Problem 3 - Pro Graphs - Fall 2016
% Re-create the figure shown in the problem, making sure to match all
% styles, colors, titles, labels, and legends.

% Use the following variables:
t = linspace(0, 2*pi, 200); % theta values
r = abs(sin(3*t)); % polar flower, Cartesian sine wave

% setup figure
figure(1);

% set current to first subplot and plot red polar flower
subplot(2,2,1);
polar(t,r,'r*');
title('Polar: |sin3\theta|');

% set current to second subplot and plot green cartesian
subplot(2,2,2);
plot(t,r,'gp');
xlim([0,max(t)]);
title('Cartesian: |sin3\theta|');

% set current to third subplot and plot plotyy
subplot(2,2,3);
plotyy(t,sin(t),t,exp(t));
xlim([0,max(t)]);
title('Plotyy: sin(t) vs. exp(t)');
legend('sin(t)','exp(t)');
ylabel('sin(t)');
yyaxis right;
ylabel('exp(t)');

% set current to fourth subplot and plot bar graph
subplot(2,2,4);
bar([2:6;6:-1:2]);
set(gca,'XTickLabel', {'Ascending','Descending'});
ylim([0,8]);
title('Bar Graph: 2:1:6 vs. 6:-1:2');

%% Independent Portion

