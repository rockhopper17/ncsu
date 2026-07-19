% clear all vars and plots
close all; clear all; clc;

% ex 2.1: car cruise control
s = tf('s');  % func to create transfer function
sys = (1/1000) / (s + 50/1000); % something for tf
step(500*sys); % just plots step response

