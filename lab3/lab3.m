% Andrew Navratil
% MAE 451 Expr Aero 3 Fall 2019
% Lab 3 Propeller Analysis
% Due 2019-10-18

% clear all vars and plots
close all; clear all; clc;

% constants
rho = 1.18; % air density [kg/m^3]

in_to_m = 0.0254; % conversion in to m [m/in]
lb_to_N = 4.4482; % conversion lb to N [N/lb]
inlb_to_Nm = 0.113; % conversion in-lb to Nm [in-lb/Nm]
psf_to_pa = 47.88; % conversion for psf to Pascal [Pa/psf]
%ms_to_ins = 39.37; % velocity conversion [m/s] to [in/s]

% load data
data = load('data/Lab-3_prop_data_all_sessions.dat');

% get list of unique propellers before converting to SI units
combocols = [data(:,1) data(:,2) data(:,3)];
[B,~,ib] = unique(combocols,'rows');
%numoccurrences = accumarray(ib,1);
propsidx = accumarray(ib, find(ib), [], @(rows){rows});

propnum = data(:,1); % no. of props
propdiam = data(:,2) * in_to_m; % prop diam [in]
proppitch = data(:,3) * in_to_m; % prop pitch [in]
throttle = data(:,4);
uinf = sqrt(2*data(:,5)*psf_to_pa/rho); % vel from qpsf [psf]
volts = data(:,6);
amps = data(:,7);
thrust = data(:,8) * lb_to_N; % thrust [lb]
torque = data(:,9) * inlb_to_Nm; % torque [in-lb]
rotpersec = data(:,10)/60; % rpm to rotations/sec
material = data(:,11); % material (1 - APC, 2 - Wood)

% calculate characteristics
J = uinf ./ (rotpersec .* propdiam); % advanced ratio
CT = thrust ./ (rho * rotpersec.^2 .* propdiam.^4); % thrust coeff
CQ = torque ./ (rho * rotpersec.^2 .* propdiam.^5); % torque coeff
CP = (volts .* amps) ./ (rho * rotpersec.^3 .* propdiam.^5); % power coeff

etaCT = CT;
etaCT(etaCT<0) = 0; % set negative thrusts to zero for efficiency calculation
eta = etaCT .* J ./ (2*pi * CQ);

% plots for each propeller (7 plots)
for idx = 1:length(B)
	figure;
	plot(J(propsidx{idx}),CT(propsidx{idx}),'bo','DisplayName','C_{T}','LineWidth',2);
	hold on; grid on;
	plot(J(propsidx{idx}),CQ(propsidx{idx})*10,'g*','DisplayName','C_{Q} (x10)','LineWidth',2);
	plot(J(propsidx{idx}),CP(propsidx{idx}),'r+','DisplayName','C_{P}','LineWidth',2);
	plot(J(propsidx{idx}),eta(propsidx{idx}),'cv','DisplayName','\eta','LineWidth',2);
	ylabel('C_{T}/C_{Q}/C_{P}/\eta');
	xlabel('J');
	title(['APC Propeller: ' num2str(B(idx,2)) ' x ' num2str(B(idx,3)) ' ('...
		num2str(B(idx,1)) ' blades)']);
	set(gca,'FontSize',14);
	legend('location','northeast');
end

% plots for parametric study (4 characteristics x 3 variations = 12 plots)
for variation = 1:3
	for characteristic = 1:4
		if variation == 1
			idxB = find(B(:,1)==2 & B(:,3)==8);
			dtitle = 'Propeller Diameter';
		elseif variation == 2
			idxB = find(B(:,1)==2 & B(:,2)==10);
			dtitle = 'Propeller Pitch';
		else
			idxB = find(B(:,3)==8 & (B(:,2)==10 | B(:,2)==10.5));
			dtitle = 'Number of Blades';
		end

		figure;
		for idxBn = 1:length(idxB)
			idx = idxB(idxBn);
			if variation == 3
				dname = [num2str(B(idx,2)) ' x ' num2str(B(idx,3))...
					' (' num2str(B(idx,1)) ' blades)'];
			else
				dname = [num2str(B(idx,2)) ' x ' num2str(B(idx,3))];
			end

			if characteristic == 1
				plot(J(propsidx{idx}),CT(propsidx{idx}),'o','DisplayName',dname,'LineWidth',2);
				ylabel('C_{T}');
			elseif characteristic == 2
				plot(J(propsidx{idx}),CQ(propsidx{idx})*10,'*','DisplayName',dname,'LineWidth',2);
				ylabel('C_{Q} (x10)');
			elseif characteristic == 3
				plot(J(propsidx{idx}),CP(propsidx{idx}),'+','DisplayName',dname,'LineWidth',2);
				ylabel('C_{P}');
			else
				plot(J(propsidx{idx}),eta(propsidx{idx}),'v','DisplayName',dname,'LineWidth',2);
				ylabel('\eta');
			end
			hold on; grid on;
		end
		xlabel('J');
		title(dtitle);
		set(gca,'FontSize',14);
		legend('location','northeast');
	end
end

