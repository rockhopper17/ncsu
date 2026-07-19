% Andrew Navratil
% 2017-10-12
% Section #205
% Homework 5

%% call convertFtoC

% prompt user for min and max temps
tmin = input('Input the min degrees (in Fahrenheit): ');
tmax = input('Input the max degrees (in Fahrenheit): ');

% call the conversion function
[F,C] = convertFtoC(tmin,tmax);

% print a table of the conversions
fprintf('Fahrenheit\tCelsius\n');
fprintf('%10.2f%12.2f\n',[F;C]);

%% example run for ellipsePlot

ellipsePlot(3.5,2.0,8.5,3);

%% call promptNVec

promptNVec;

%% call mySSL

mySSL;

%% ezample run for myFlip

f = magic(5);
flip_f = myFlip(f);
