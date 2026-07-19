% hw4 #5 - plot viscoelastic creep test for Voigt model

% clear all vars and plots
close all; clear all; clc;

% solution of 1st order ODE
s = 1; E = 2; nu = 1;

f = @(t) (s/E) * (1 - exp(-E*t/nu));
f = @(t) 1-exp(-t);

figure;
fplot(f);
%axis([0 100 0 1000]);
