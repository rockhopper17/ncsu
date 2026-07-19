% Andrew Navratil
% MAE 451 Expr Aero 3 Fall 2019
% Lab 5 Electric Motor Performance Analysis
% Due 2019-11-11

% clear all vars and plots
close all; clear all; clc;

% load data
files = dir('data/*.dat');

col={'bo', 'g*', 'rv', 'co', 'm*', 'yv'};
for idx = 1:numel(files)
	fname = files(idx).name;
	data = load(fullfile(files(idx).folder, fname));

	rpm = data(:,1); 
	torque = data(:,2)/1e3; % data:N-mm convert:N-m
	volts = data(:,3);
	amps = data(:,4);
	mr = strcat('M',num2str(fname(6)),' R',num2str(fname(11)));

	powin = volts .* amps;
	powout = 2*pi*(rpm/60).*torque; % data:rpm convert:rps
	eff = powout./powin;

	figure(1);
	plot(rpm,torque,col{idx},'LineWidth',2,'DisplayName',mr);
	hold on; grid on;
	ylabel('Torque (N-m)');
	xlabel('RPM');
	ylim([0 0.5]);
	xlim([0 11000]);
	legend('location','northeast');
	set(gca,'FontSize',14);

	figure(2);
	plot(rpm,powin,col{idx},'LineWidth',2,'DisplayName',mr);
	hold on; grid on;
	ylabel('Power in (W)');
	xlabel('RPM');
	ylim([0 1200]);
	xlim([0 11000]);
	legend('location','northeast');
	set(gca,'FontSize',14);

	figure(3);
	plot(rpm,powout,col{idx},'LineWidth',2,'DisplayName',mr);
	hold on; grid on;
	ylabel('Power out (W)');
	xlabel('RPM');
	ylim([0 250]);
	xlim([0 11000]);
	legend('location','northwest');
	set(gca,'FontSize',14);

	figure(4);
	plot(rpm,eff,col{idx},'LineWidth',2,'DisplayName',mr);
	hold on; grid on;
	ylabel('Efficiency');
	xlabel('RPM');
	ylim([0 0.5]);
	xlim([0 11000]);
	legend('location','northwest');
	set(gca,'FontSize',14);
end
