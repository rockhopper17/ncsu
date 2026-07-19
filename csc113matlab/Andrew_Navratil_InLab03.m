% Name Andrew Navratil
% Date 2017-09-07
% Section #205
% In-Lab 3

clear all; close all; clc %clear functions
%% Instructor-Guided Portion
%% Problem 1 - M-m-m-money
% Write an if statement to calculate an employee's weekly pay.
% The employee makes $15 for the first 40 hours in the week.
% For every additional hour beyond 40, the employee makes time-and-a-half.

% Input variable:
hours = 45; % num hours worked
pay = 15;   % pay per hour

format bank;

% Conditional if statement:
if hours <= 40
    paycheck = hours * pay;
elseif hours > 40 && hours < 80
    paycheck = (pay * 40) + ((hours-40) * (pay * 1.5))
else
    disp('Too many hours');
end

format short;

%% Problem 2 - Trip Calculator
% Use a switch/case statement to display the travel distance from Raleigh.
% Use a menu to get input from the user, print distance to command window.

% Menu to produce input:
place = menu('Select a city: ','Wilmington', 'Charlotte', 'Miami', 'NYC');

% Switch/Case to select mileage:
switch place
    case 1
        mileage = 140;
    case 2
        mileage = 162;
    case 3
        mileage = 806;
    case 4
        mileage = 492;
    otherwise
        mileage = 0;
        disp('No place chosen');
end

% Print (unsuppressed) to command window:
fprintf('It will take %d miles\n', mileage);


%% Problem 3 - Matrix Manipulation and formatting
% Use the given max temperatures to perform the listed operations.

% Temps for Aug 2014 from NOAA:
temps = [76 70 80 85 88 90 86 81 74 81 84 87 82 83 86 89 89 88 86 90 ...
    91 92 84 81 79 82 86 92 82 89 91];
    % Note: use "..." to continue code onto next line

% Find the average, and the number of days the temp was above average:
avg = mean(temps);
day = sum(temps > avg);

% Find the number of days where the temp ranged 80-90°F
hotdays = sum(temps > 80 & temps < 90);

% Find the modal temp and which days this temp occurred (use find() )
mode_temps = mode(temps);
location_mode = find(temps == mode_temps);


%% Independent Portion
% See Cody Coursework for problems

mat = ceil(5*rand(4));

a = sum(mat(:,1) == 5);
b = sum(mat(2,:) == 1);
c = sum(sum(mat == 3));
d = sum(sum(mat > 3));

%% indep 2
bars = 2;

format bank;
switch bars
  case 1
     candy_cost = 0.75;
  case 2
     candy_cost = 1.25;
  case 3
     candy_cost = 1.65;
  otherwise
     candy_cost = 1.65 + ((bars - 3) * 0.30);
end

%% indep 3

n = 1200;

format bank;
if n <= 500
  cost = (n * .02);
elseif n > 500 && n < 1000
  cost = 10 + ((n-500) * .05);
else
  cost = 35 + ((n-1000) * .10);
end

cost = cost + 5;

%% indep 4


num = 1;

if rem(num,10) < 5
    rnum = floor(num / 10) * 10;
else
    rnum = ceil(num / 10) * 10;
end