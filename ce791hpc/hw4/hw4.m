close all; clear all; clc;

%==========================================================
% pi example
%==========================================================
if 0
	% fpi executed on henry2 where mflops,time,numprocs printed to console and copied here
	procs = [1 2 4 8]
	times = [3.560080528259277E-003 1.791508197784424E-003 ...
		9.223484992980957E-004 4.815793037414551E-004]
	mflops = [1123 2233 4421 8582]

	plot(procs,times,'*k--','MarkerSize',10);
	xlabel('Number of Processors');
	ylabel('Elapsed Time (s)');
	set(gca,'FontSize',16);

	figure;
	plot(procs,mflops,'*b--','MarkerSize',10);
	xlabel('Number of Processors');
	ylabel('Mflops');
	set(gca,'FontSize',16);
%==========================================================
% water supply
%==========================================================
elseif 1
	% water_supply_vector.f executed on henry2
	%   mflops,time,numprocs printed to console and copied here
	procs = [1 2 4 8]
	times = [4.30857939720154 4.37197232246399 4.58475260734558 4.67490670681000]
	mflops = [219 216 206 201]

	plot(procs,times,'*k--','MarkerSize',10);
	xlabel('Number of Processors');
	ylabel('Elapsed Time (s)');
	set(gca,'FontSize',16);

	figure;
	plot(procs,mflops,'*b--','MarkerSize',10);
	xlabel('Number of Processors');
	ylabel('Mflops');
	set(gca,'FontSize',16);
end
