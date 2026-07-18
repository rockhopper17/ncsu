close all; clear all; clc;

% part 1: matrix vector product
if 0
procs = [2 4 8 16]
mflops100henry = [75 126 33 1.8]
mflops1000henry = [123 144 143 149]
mflops100bezier = [27 32 32 38]
mflops1000bezier = [77 274 297 302]

figure;
plot(procs,mflops100henry,'*-','DisplayName','Mflops henry 100x100');
hold on;
plot(procs,mflops1000henry,'+-','DisplayName','Mflops henry 1000x1000');
plot(procs,mflops100bezier,'.-','DisplayName','Mflops bezier 100x100');
plot(procs,mflops1000bezier,'^-','DisplayName','Mflops bezier 1000x1000');
xlabel('Number of Processors');
ylabel('Mflops');
set(gca,'FontSize',16);
legend('location','northwest');

% part 2: monte-carlo integration
elseif 1
procs = [2 4 8 16]
mflopshenry = [213 325 346 351]
mflopsbezier = [42 35 4 2]

figure;
plot(procs,mflopshenry,'*-','DisplayName','Mflops henry');
hold on;
plot(procs,mflopsbezier,'.-','DisplayName','Mflops bezier');
xlabel('Number of Processors');
ylabel('Mflops');
set(gca,'FontSize',16);
legend('location','northwest');


end
