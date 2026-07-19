% Name: Andrew Navratil
% Date: 2017-10-19
% Section #205
% In-Lab 7

clear all; close all; clc % clear functions
%% Instructor-Guided Portion
%% Problem 1 - Sorry Pluto :( 
% Download planets.xlsx from Moodle and perform the operations. 

% Import the data set using xlsread():
[~,~,raw] = xlsread('planets.xlsx');

% a. Create a padded character array containing the planets’ names:
names = char(raw{:,1});

% b. Create a double-precision array containing the planets’ masses:
mass = [raw{:,2}];

% c. Create a cell array containing the planets’ year lengths:
year = raw(:,3);

% d. Create a double-precision array that with the mean orbital velocities:
orb = cell2mat(raw(:,4));

% e. Store the arrays created in parts a-d in a structure array:
for i = 1:length(raw)
	planets(i).name = names(i,:);
	planets(i).mass = mass(i);
	planets(i).year = year{i};
	planets(i).orb = orb(i);
end
	

% f. Index given variables:
% i. Name of Mars:
mars = planets(4).name;

% ii. Mass of Jupiter:
jup = planets(5).mass;

% iii. Year length of Neptune:
nep = planets(8).year;

% iv. Mean orbital velocity of Earth:
earth = planets(3).orb;

%% Problem 2 - Textscan()

% Open file CFR1869to2010.txt after donwloading it from moodle.
fid = fopen('CFR1869_2010.txt');

% Use textscan() to import data from the file.
fbData = textscan(fid,'%d %s %f %f %f %f %f','Delimiter',':,');

% Close file
fclose(fid);

% Begin loop to create structure
for n = 1:length(fbData{1})
	% fieldnames cannot have spaces	
	fieldname = strrep(fbData{2}{n},' ','');
	
	fbStats.(fieldname).rank = fbData{1}(n);
	fbStats.(fieldname).totalPts = fbData{3}(n);
	fbStats.(fieldname).winPct = fbData{4}(n)/10;
	fbStats.(fieldname).bowlRank = fbData{7}(n);
end


%% Problem 3 - Thermocouples 
% Load thermocouple.dat from Moodle and organize the data into separate
% text files.

% Import thermocouple data file:
fid = load('thermocouple.dat');

% Print each sensor data to a separate .txt file:
[~,c] = size(fid);  % gets the number of columns

for j = 1:c
	namefile = sprintf('Thermocouple%d.txt',j);

	fid1 = fopen(namefile,'w');
	fprintf(fid1,'%.1f\n',fid(:,j));
end

% Close the files:
fclose('all');

%% Independent Portion

