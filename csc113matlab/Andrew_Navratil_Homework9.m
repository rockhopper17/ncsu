% Andrew Navratil
% 2017-11-16
% Section #205
% Homework 9

clear;close all;clc;

%% 1. Noisy image simulation

% load image and get size - using NCSUBellTower.jpg for testing
mat = imread('photo1.jpg');
[matr,matc,matp] = size(mat);

% sample n value
n = 125;

% randomly add or subtract n: +1 is add, -1 is subtract
matrand = rand(matr,matc,matp);  % first get random values between 0 and 1
ind = matrand >= 0.5;       % then get any numbers greater than 0.5
matrand(ind) = 1;           % set all these to 1
matrand(~ind) = -1;         % set the rest to -1

% now multiply matrand by our n and add to mat, which does the addition or subtraction
% based on whether it's +n or -n, first casting both to the same datatype int16
newmat = int16(matrand * n) + int16(mat);

% now convert back to uint8 to match image matrix datatype, also takes care of any additions
% or subtractions that go below 0 or above 255
newmat = uint8(newmat);

% display new image along with original using subplot and imshow
figure(1);

% plot original image
subplot(1,2,1);
imshow(mat);
title('Before','FontSize',14);

% now plot new image
subplot(1,2,2);
imshow(newmat);
title(sprintf('After when n = %d',n),'FontSize',14);

%% 2. magic squares with colormap

% first generate figure
figure(2);

% set colormap
%colormap('autumn');
colormap('parula');

% loop with magic function and plot
for i = 2:13
	subplot(3,4,i-1);   % set subplot correctly
	image(magic(i));  % plot the magic function
	title(sprintf('magic(%d)',i));  % set the correct title
end

%% 3. static animation

% setup figure for animation
figure(3);

% create custom colormap
white = [1 1 0];
black = [0 .2345 0];
myColors = [white;black];  % white = 1, black = 2
colormap(myColors);

% number of iterations to perform
n = 200;

% loop for n iterations to animate
for i = 1:n
	% create random 50x50 matrix of 1s and 2s, where 1 = white and 2 = black
	mat = randi([1 2],50,50);
	image(mat)
	pause(0.05);  % step value for varying the speed of animation
end

%% 4. radio colors gui

% call radio_colors_GUI function (renamed from _template)
radio_colors_GUI();

%% 5. play sound for chosen number of repetitions

% sound names
snames = {'Gong','Chirp','Train','Laughter'};

% menu for sound selection
s = menu('Select Sound',snames{1},snames{2},snames{3},snames{4});

% set sound name based on option selected 
sname = snames{s};

% menu for num iterations
n = menu(sprintf('Select number of times to play %s',sname),'1','2');

% first load the chosen sound
load(lower(sname));

% calculate time the sound will play for based on num samples and sample rate
t = numel(y)/Fs;

% play sound for chosen number of iterations
for i = 1:n
	% play the sound - variables y and Fs were created by the call to load
	sound(y,Fs);
	
	% pause for the corresponding amount of time plus a little bit
	pause(t + 0.5);
end

