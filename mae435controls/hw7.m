% clear all vars and plots
close all; clear all; clc;

% use s method for writing transfer functions
s = tf('s');

%H = 2000/(s*(s+2000));
%H = 1/((s+1)^2*(s^2+2*s+4));
%H = 4*s*(s+10)/((s+100)*(4*s^2+5*s+4)); % #1c

%K = 3.9;
%H = K*(s+1)*(s+2)/(s^2*(s+3)*(s^2+2*s+25)); % #2

% #3
%K = 100;
%K = 100;
%H = K*1000/(s*(s+5)*(s+200))
%H = K/(s*((1/5)*s+1)*((1/200)*s+1))
%H2 = H*((1/0.75)*s+1)/((1/2.25)*s+1)

% #4
K = 10;
H = K*(10*s+1)*10^2/(s*(s^2+2*10*0.16*s+10^2));
%H2 = (10000*s^2+2000*s+10000)/(s^2*(s+10)*(s^2+20*s+10000));

bode(H)
%figure
%bode(H2)
%margin(H)
%margin(H2)
%[mag,phase,wout] = bode(H);

%figure
%rlocus(H)
