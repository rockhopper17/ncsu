% Name: Andrew Navratil
% Date: 2017-11-09
% Section #205
% In-Lab 9

clear all; close all; clc % clear functions
%% Instructor-Guided Portion
%% Problem 1 - No Green
% Download NCSUBellTower.jpg from Moodle. 

% Load the image file:
mat = imread('NCSUBellTower.jpg');

% Set green values to 0 and display the new image:
mat(:,:,2) = 0;
image(mat);

% Find the max and min values:
maxVal = max(max(max(mat)));
minVal = min(min(min(mat)));

%% Problem 2 - Colormap Window
% Create a custom colormap and generate the quandrant image.

% Create a custom colormap:
white = [1 1 1];
green = [0 1 0];
red = [1 0 0];
blue = [0 0 1];

% creates colormap matrix
% 1 = white, 2 = green, 3 = red, 4 = blue
myColors = [white;green;red;blue];
colormap(myColors);

% Create image matrix:
wheel = ones(50,50);
wheel(1:25,26:50) = 2;
wheel(26:50,1:25) = 3;
wheel(26:50,26:50) = 4;

% Display image:
image(wheel);

%% Problem 3 - Sounds
% Load built-in sounds and combine them.

% Load built-in sound 'gong':
load gong;
gongY = y;
gongFs = Fs;

% Load built-in sound 'chirp':
load chirp;
chirpY = y;
chirpFs = Fs;

% Combine sounds:
yFinal = [gongY;chirpY];
sound(yFinal,Fs);

% Plot the combined sounds:
figure(1);
plot(yFinal);
title('Gong and Chirp Combined');

%% Problem 4 - Color GUI
% Complete the color GUI template to create an interactive figure.

% Call GUI Function:
colorGUI

%% Independent Portion

%% 5. black and white images
% create custom colormap
white = [1 1 1];
black = [0 0 0];
myColors = [white;black];  % white = 1, black = 2
colormap(myColors);

% create random 10x10 matrix of 1 or 2
yin = randi([1 2],10,10);

% swap all vaues in yin and put in yang
yang = yin;
yang(yang == 1) = 3;
yang(yang == 2) = 1;
yang(yang == 3) = 2;

% create new figure
figure(1);

% plot yin
subplot(1,2,1);
image(yin);
title('Yin');

% plot yang
subplot(1,2,2);
image(yang);
title('Yang');

%% call displayMosaic

displayMosaic('NCSUBellTower.jpg',2,3);

%% 6. sounds

% create structure with sounds

load chirp;
sounds(1).y = y;
sounds(1).Fs = Fs;

load gong;
sounds(2).y = y;
sounds(2).Fs = Fs;

load laughter;
sounds(3).y = y;
sounds(3).Fs = Fs;

load train;
sounds(4).y = y;
sounds(4).Fs = Fs;

radio_sounds_GUI(sounds);

