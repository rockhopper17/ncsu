% clear all vars and plots
close all; clear all; clc;

% plot CL vs CM
devals = [-5 0 5 10]; % elevator angle values
knvals = [0 0.1 0.2]; % static margin values
CL = [0:0.1:1]; % chosen CL range, nothing was given
ltype = {'k-','k--','k-.','k:','r-','r--','r-.','r:','b-','b--','b-.','b:'};

CM = repmat(knvals,numel(devals),1);
CM = CM.*devals';

set(0, 'DefaultLineLineWidth', 2);
idx = 1;
for kn = knvals
	for de = devals
		CM = -kn*CL + 0.1*(0.5 - 0.1*de);
		plot(CL,CM,ltype{idx},'DisplayName',['kn ',num2str(kn),', de ',num2str(de)]);
		hold on;
		idx = idx + 1;
	end
end

ylabel('C_M');
xlabel('C_L');
grid on;
ylim([-.3 .2]);
set(gca,'FontSize',14);
legend('location','eastoutside');

% plot detrim vs CLtrim
figure;
set(0, 'DefaultLineLineWidth', 2);

idx = 1;
for kn = knvals
	de = -kn*CL*100 + 5;
	plot(CL,de,ltype{idx},'DisplayName',['kn ',num2str(kn)]);
	hold on;
	idx = idx + 4;
end

ylabel('\delta_{e-trim}');
xlabel('C_{L-trim}');
grid on;
ylim([-20 10]);
set(gca,'FontSize',14);
legend('location','eastoutside');
