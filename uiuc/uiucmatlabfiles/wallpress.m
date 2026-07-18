%x_exp: sensor locations from the inlet tip [mm]
%p_exp: pressure data of each sensor [Pa]
%time: time stamps of data acquisition [sec]
%p_Fuel_total: total pressure of fuel [Pa]
%p_ple1: total pressure of freestream [Pa]
%phi: global equivalence ratio

%whos output:
%p_Fuel_total      20000x1              160000  double                
%p_exp             20000x17            2720000  double                
%p_ple1            20000x1              160000  double                
%phi                   1x1                   8  double                
%time              20000x1              160000  double                
%x_exp                 1x17                136  double    

close all; clear all; clc;

% load the data
%fname = '180714_RUN002';  % ER 0.7786
%fname2 = '180714_RUN003';  % ER 0.8157
fname = '180714_RUN006';  % ER 1.2704
%fname = '180714_RUN013';  % ER 1.2429
fname2 = '180714_RUN014';  % ER 1.0619
%fname = '180714_RUN021';  % ER 0.8226

%fname = '180718_RUN002';  % ER 1.365
%fname = '180718_RUN010';  % ER 1.553

% ==================================================================
% ignition delay plot - will load a second mat for comparison from fname2

if true

load([fname,'.mat'])
%tidx1a = find(time == 0.27);
%tidx1b = find(time == 0.34);
%tidx2a = find(time == 0.37);
%tidx2a = find(time == 0.4);
%tidx2a = find(time == 0.33);
%tidx2b = find(time == 0.45);

% for low ERs ~0.8 (714 runs 2,3)
%tidxa = find(time == 0.28);
%tidxb = find(time == 0.45);
% for larger ERs with two distinct intervals
%tidxa = find(time == 0.28);
%tidxb = find(time == 0.34);
tidxa = find(time == 0.40);
tidxb = find(time == 0.45);

figure;
avgp = mean(p_exp(tidxa:tidxb,:));
rmsp = std(p_exp(tidxa:tidxb,:));
%plot(x_exp,avgp2,'ro-','DisplayName',['ER ',sprintf('%.2f',phi),' avg']);
errorbar(x_exp,avgp,rmsp,'ro-','DisplayName',['ER ',sprintf('%.2f',phi),' avg']);
hold on;

ylim([0 max(max(p_exp))]);

% save data out to txt file
T = table(x_exp',avgp',rmsp', 'VariableNames', { 'X','P','P_rms'} );
writetable(T, [fname,'.txt'])

% load and plot data from second mat file
load([fname2,'.mat'])

avgp = mean(p_exp(tidxa:tidxb,:));
rmsp = std(p_exp(tidxa:tidxb,:));
errorbar(x_exp,avgp,rmsp,'bo-','DisplayName',['ER ',sprintf('%.2f',phi),' avg']);

title(sprintf('time %.2fs to %.2fs',time(tidxa),time(tidxb)));
xlabel('x (mm)');
ylabel('sensor pressure (Pa)');
set(gca,'FontSize',18);
legend('location','northeast');

% save data out to txt file
T = table(x_exp',avgp',rmsp', 'VariableNames', { 'X','P','P_rms'} );
writetable(T, [fname2,'.txt'])

end

%====================================================
% movie creation

if false

load([fname,'.mat'])
writerObj = VideoWriter([fname,'.m4v'],'MPEG-4');
N = length(time(:)); 
runtime = 100;  % num seconds to run movie
frate = N/runtime;
writerObj.FrameRate = frate;
open(writerObj);

% plot, animate, and create movie
for tidx = 1:N
	plot(x_exp,p_exp(tidx,:),'o-');
	title(sprintf('ER %1.3f at time %1.6f sec',phi,time(tidx)));
	xlabel('x (mm)');
	ylabel('sensor pressure (Pa)');
	ylim([0 max(max(p_exp))]);
	%ylim([min(min(p_exp)) max(max(p_exp))]);
	set(gca,'FontSize',18);

	writeVideo(writerObj,getframe(gcf));
end 

close(writerObj);

end
