% time frequency analysis

% clear all vars and plots
close all; clear all; clc;

load('svddata_horn.mat');

sigx = amp_x(500,:);
t = t;

%dt = mean(diff(t));
%Fs = 1 / dt;
% logic pulled from polytec sample CalculateFFT.m
Fs = (usd_x.XCount - 1) / (usd_x.XMax - usd_x.XMin);

figure
subplot(3,1,1)
plot(t*1e6,sigx*1e3)
xlabel('time [\mus]')
ylabel('amplitude (x velocity [mm/s])')
title('signal x vel at pos 500')

subplot(3,1,2)
%pspectrum(sigx)
pspectrum(sigx,Fs,'Leakage',1,'FrequencyLimits',[100e3, 600e3])
subplot(3,1,3)
pwelch(sigx,[],[],[],Fs)

% played with various wl vals (sample window width), still only getting one value
figure
env = envelope(sigx,80,'rms');
%env = envelope(sigx,80,'peak');
%env = envelope(sigx,80,'analytic');
%plot(t,env);  % do this to see what the actual envelope looks like
pulsewidth(env,Fs)
