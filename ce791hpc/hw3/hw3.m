% Andrew Navratil
% CE 791 HPC - HW 3

close all; clear all; clc;

% use readmatrix since file has column names at top
% modified driver.c to include tab delimter
m = 'henry'; % machine name: bezier, neer, henry

d = readmatrix(['hw3data/matmulc_' m '_ofast.dat']);
plot(d(:,1),d(:,2),'+k:','MarkerSize',10,'DisplayName','naive loop w Ofast');
hold on;

%d = readmatrix(['hw3data/matmulc_' m '_o1.dat']);
%plot(d(:,1),d(:,2),'+b-','MarkerSize',10,'DisplayName','naive loop w O1');

%d = readmatrix(['hw3data/matmulc_' m '_o2.dat']);
%plot(d(:,1),d(:,2),'+b-.','MarkerSize',10,'DisplayName','naive loop w O2');

%d = readmatrix(['hw3data/matmulc_' m '_o3.dat']);
%plot(d(:,1),d(:,2),'+b--','MarkerSize',10,'DisplayName','naive loop w O3');

d = readmatrix(['hw3data/matmulc_' m '_mkl.dat']);
plot(d(:,1),d(:,2),'xk-','MarkerSize',10,'DisplayName','intel mkl dgemm');

d = readmatrix(['hw3data/matmulc_' m '_restruct.dat']);
plot(d(:,1),d(:,2),'*k--','MarkerSize',10,'DisplayName','loop restructure');

d = readmatrix(['hw3data/matmulc_' m '_blocking.dat']);
plot(d(:,1),d(:,2),'ok-.','MarkerSize',10,'DisplayName','blocking');

xlabel('Matrix Size');
ylabel('Mflops');
title(m);
%title([m ' (2)']);
set(gca,'FontSize',18);
legend;

