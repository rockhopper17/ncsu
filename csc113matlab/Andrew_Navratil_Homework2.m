% Andrew Navratil
% 2017-09-07
% Section #205
% Homework 2

%% Problem 1 - Projectile Plot
% not using functions yet, so using the following values for initial data:
%    time = 15 sec
%    init velocity = 100 m/s
%    launch angles = 30, 45 degrees

% use hold for multpiple graphs on the same plot and setup figure window
figure(1);
hold on;

% setup times to plot
times = linspace(0,15,100);

% setup init velocity and g
initVelocity = 100;
g = 9.81;

% setup launch angles
launchAngles = [30; 45];

% compute horizontal and vertical components of projectile motion
horizDist = times .* initVelocity .* cosd(launchAngles);
vertDist = (times .* initVelocity .* sind(launchAngles)) - ((times.^2) .* 0.5 .* g);

% plot (should probably use for loop here when we learn that)
plot(horizDist(1,:), vertDist(1,:));  % 30 degrees
plot(horizDist(2,:), vertDist(2,:));  % 45 degrees

% setup title, legend, axis labels
title('Projectile trajectories for init vel = 100 m/s over 15 sec');
legend('30^o launch angle','45^o launch angle');
xlabel('Horizontal Distance (m)');
ylabel('Vertical Distance (m)');

% find max heights and print out to command window
%   (note: just using max on time interval calculated, not derivative of vertical distance / max height formula)
%   concatenate the 2 launch angles (column vector) with the transpose of the max in each row (using dim 2 in max
%   command) which gives a row vector, giving the 2x2 matrix we want
fprintf('Max height reached from %d degree launch angle is %.2fm\n', [launchAngles, max(vertDist,[],2)]');


%% Problem 2 - multiplication table
% multiplication table from 1 to 13 for user inputted value
maxMult = 13;
num = input('Enter number to view multiplication table: ');

% setup a 3x13 matrix so fprintf can go through it column wise
%     use 1:maxMult to get 1 through (13) in the first row
%     use repmat to get the inputed number all across the second row
%     use a double colon operator with inputed number as increment value
%         to get the actual result of a multplication for (1 - maxMult) .* num
multTable = [1:maxMult; repmat(num,1,maxMult); num:num:num*maxMult];

% print using a single fprintf statement - it reads column wise
fprintf('%d times %d is %d\n', multTable);

%% Problem 3 - ACE Index excel plot

% import the ACE data from excel
[data,~,~] = xlsread('ACE.xlsx');

% pull out data for year, num hurricanes, and num major hurricanes (cat 3 - 5)
years = data(:,1);
numHurricanes = data(:,4);
numMajorHurricanes = data(:,5);

% plot num hurricanes and num major hurricanes on same plot vs year
figure(1);
hold on;
grid on;
plot(years, numHurricanes, '-ro')
plot(years, numMajorHurricanes, '--bo');
title('Hurricane Activity');
ylabel('Number of Hurricanes');
xlabel('Year');
legend('Hurricanes Cat. 1-5', 'Major Hurricanes Cat. 3-5');

% determine which year had highest values for the following, and print to command window:

%   ACE Index
[val, idx] = max(data(:,2));
maxACEIdxYear = data(idx,1)

%   Num Tropical Storms
[val, idx] = max(data(:,3));
maxNumTropStormsYear = data(idx,1)

%   Num Hurricanse
[val, idx] = max(data(:,4));
maxNumHurricanesYear = data(idx,1)

%   Num Major Hurricanes
[val, idx] = max(data(:,5));
maxNumMajorHurricanesYear = data(idx,1)

%% Problem 4 - subplot examples

% setup figure 1
figure(1);

% angle values
x = linspace(-pi, pi, 50);

% set current to first subplot and plot sin(x)
subplot(3,1,1);
plot(x,sin(x),'dr');
title('sin(x)');

% set current to second subplot and plot cos(x)
subplot(3,1,2);
plot(x,cos(x),'pg');
title('cos(x)');

% set current to third subplot and plot tan(x)
subplot(3,1,3);
plot(x,tan(x),'ob');
title('tan(x)');

% setup figure 2
figure(2);

% angle values
x = linspace(-5, 5, 50);

% set current to first subplot and plot x^1
subplot(1,3,1);
plot(x,x,'xc');
title('x^1');

% set current to second subplot and plot x^2
subplot(1,3,2);
plot(x,x.^2,'+m');
title('x^2');

% set current to third subplot and plot x^3
subplot(1,3,3);
plot(x,x.^3,'sy');
title('x^3');

%% Problem 5 - cold_work.dat plotyy

% setup figure
figure(1);

% import .dat file using load command 
data = load('cold_work.dat');

% pull out data
dataColdWork = data(:,1);
dataYieldStrength = data(:,2);
dataDuctility = data(:,3);

h = plotyy(dataColdWork,dataYieldStrength,dataColdWork,dataDuctility);
title('Yield Strength vs Ductility at values of percent cold work');
xlabel('Percent Cold Work');
%legend('Yield Strength','Ductility');
set(get(h(1),'YLabel'),'String','Yield Strength, MPa');
set(get(h(2),'YLabel'),'String','Ductility, %');
%ylabel('Yield Strength, MPa');
%yyaxis right;  % this wasn't working, resulting in messed up axis values
%ylim([0,max(dataDuctility)]);
%ylabel('Ductility, %');

%% Problem 6 - input playing cards

% prompt user for card number and suit
cardnum = input('Pick a card number: ');
suit = input('Pick a card suit: ','s');

% ouptput using fprintf
fprintf('\nUsing fprintf:\n');
fprintf('You selected the %d of %s.\n\n',cardnum,suit);

% output using disp
%str = sprintf('\nUsing disp:');
disp('Using disp:');
str = sprintf('You selected the %d of %s.',cardnum,suit);
disp(str);
