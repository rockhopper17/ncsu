%% CSC 113, Lina Battestilli, fprintf usage
% This script calculates the area of a circle
% It prompts the user for the radius
 
clear; clc;

% Prompt the user for the number of circles, min & max radii
numCircles = input('Number of circles: ');
radius_min = input('Enter the min radius in inches: ');
radius_max = input('Enter the max radius in inches: ');

%get the radii of inner circles evenly spaced between smallest & largest
%circle
radiii=linspace(radius_min, radius_max, numCircles);

%%
%calculate the areas of all the circles
area = pi * (radiii.^2);
%put the radii and area in a table by concatenating matrices
table = [radiii; area]; 

% Print the radius and area in a table format
fprintf('Radius   Area\n', table);
fprintf('%6.2f  %.3f\n', table);
