% Andrew Navratil
% CE 791 HPC - HW 2

close all; clear all; clc;

% use readmatrix since file has column names at top
% modified vecbench.c to include tab delimter
%d = readmatrix(['hw2data/flops_c.dat']); % original MAXSIZE (1050*1050)
d = readmatrix(['hw2data/flops_c2.dat']); % modified MAXSIZE (MAXBLOCKS*BLOCKSIZE)

semilogx(d(:,1),d(:,2),'x-r','MarkerSize',10);
xline((32/24)*1024); % L1 cache 32K
xline((256/24)*1024); % L2 cache 256K
xline((20480/24)*1024); % L3 cache 20480K
xticks([4 16 64 256 1024 4*1024 16*1024 64*1024 256*1024 1000*1024]);
xticklabels({'4', '16', '64', '256', '1K', '4K', '16K', '64K', '256K', '1M'});
xlabel('Vector Size (words)');
ylabel('Mflops');
set(gca,'FontSize',18);
%axis([0 6 -.25 .25]);
%legend;

