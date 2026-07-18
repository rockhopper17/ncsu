close all; clear all; clc;

% benchmarking code executed on bezier
% mflops, exec time, num procs printed to final.out and copied in here

%procs = [1 2 4 8 16] % p3
%mflops = [670 1293 2265 2790 2653] % p3
%times = [1.792e-2 9.282e-3 5.297e-3 4.301e-3 4.522e-3] % p3

%procs = [1 2 4 8] % p4
%mflops = [3.331 0.2727 .1604 .113] % p4
%times = [3.002e-7 7.332e-6 2.494e-5 7.070e-5] % p4

% errors: v2: 1.01e-2, gs: 1.96e-2, gs openmp: 1.96e-2
%procs = [1 2 4 8 16] % p7
%mflopsv2 = [815 390 329 180 73.9]
%timesv2 = [.491 1.03 1.22 2.22 5.41]
%mflopsgs = [3193 482 361 181 78.5]
%timesgs = [.125 .830 1.11 2.20 5.09]
%mflopsopenmp = [11067 5355 3047 1355 691]
%timesopenmp = [3.61e-2 7.47e-2 .131 .295 .578]

procs = [1 2 4 8 16] % p9
times = [3.00 1.66 1.03 1.01 .990]

plot(procs,times,'*k--','MarkerSize',10);
%plot(procs,timesv2,'*--','MarkerSize',10,'DisplayName','v2');
%hold on;
%plot(procs,timesgs,'+--','MarkerSize',10,'DisplayName','RBGS');
%plot(procs,timesopenmp,'^--','MarkerSize',10,'DisplayName','OpenMP');
xlabel('Number of Processors');
ylabel('Elapsed Time (s)');
set(gca,'FontSize',16);
%legend('location','northwest');

%figure;
%plot(procs,mflops,'*b--','MarkerSize',10);
%plot(procs,mflopsv2,'*--','MarkerSize',10,'DisplayName','v2');
%hold on;
%plot(procs,mflopsgs,'+--','MarkerSize',10,'DisplayName','RBGS');
%plot(procs,mflopsopenmp,'^--','MarkerSize',10,'DisplayName','OpenMP');
%xlabel('Number of Processors');
%ylabel('Mflops');
%set(gca,'FontSize',16);
%legend('location','northeast');

