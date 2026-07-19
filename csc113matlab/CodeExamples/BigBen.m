% Script Eg13_1
% from Insight Through Computing, Ch 13, Acoustic File Processing
% Creates sound files for each of the twelve clock strikes using the
% data in BigBen.wav. 
%%

close all
% Read in the 1 O'clock sound file...
[OneOclock,rate] = audioread('BigBen1.wav');%,rate is 8000
n = length(OneOclock); %OneOclock 159802x1, # of recorded samples
%sound(OneOclock,rate) %play it

% Display the sound wave the amplitude of each sample
plot(OneOclock)

%click in between the Chimes portion and the Gong portion
title('Click at the beginning of the gong.')
[m,y] = ginput(1); %gets the coordinates of a point by clicking the mouse
m = round(m);
Chimes = OneOclock(1:m);
Gong = OneOclock(m+1:n);

% For each hourly strike, create a .wav file.
% Name them BigBen2,BigBen3...,BigBen12.
F = [Chimes; Gong]; %i.e. BigBen1
for k=2:12
    F = [F; Gong];
    fname = ['BigBen' num2str(k) '.wav'];
    audiowrite(fname, F, rate)
end

% Play back a chosen subset of the soundtracks...
PlayList = [2 5];  
for k = PlayList
    fname = ['BigBen' num2str(k) '.wav'];
    [Oclock,rate] = audioread(fname);
    sound(Oclock)
end

