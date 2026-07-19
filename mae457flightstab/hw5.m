% clear all vars and plots
close all; clear all; clc;

% density takes value from appdx D using alt h = 1500m
% *** this gives CL values greater than 1 for some reason
%rho = 1.0581; % [kg/m^3] 
rho = 1.23; % [kg/m^3]  ** use normal sea level val to get good CLs
S = 16.21; % [m^2]
g = 9.81; % [m/s^2]
xvals = [-0.1:0.1:1.2]; % CL values for x-axis
% needed to extend this further to get x-intercept
xcgvals = [2.0:0.1:3.0]; % xcg values for x-axis

% values for the 3 CG locations
xcg = [2.385; 2.205; 2.043]; % [m]
it = [1.5 0 -1.0 -2.0; 4.5 2.0 0.3 -1.0; 7.2 3.5 1.5 0]; % [deg]
vel = [40.7 48.7 56.3 69.3; 39.8 46.9 55.0 67.5; 38.9 46.0 54.5 68.0]; % [m/s]
m = [1656 1650 1649 1646; 1466 1463 1461 1458; 1293 1290 1288 1286]; % [kg]

% calculate CLtrim
CL = (m.*g)./(0.5*rho.*vel.^2*S);

% plot it vs CL (see fig 2.18 in book)
ph(1) = plot(CL(1,:),it(1,:),'ko','DisplayName','X_{cg} 2.385m');
hold on; grid on;
ph(2) = plot(CL(2,:),it(2,:),'ks','DisplayName','X_{cg} 2.205m');
ph(3) = plot(CL(3,:),it(3,:),'kd','DisplayName','X_{cg} 2.043m');
ylabel('i_t (deg)');
xlabel('C_L');
xlim([min(xvals) max(xvals)]);

% calculate linear fits and plot
p(1,:) = polyfit(CL(1,:),it(1,:),1);
p(2,:) = polyfit(CL(2,:),it(2,:),1);
p(3,:) = polyfit(CL(3,:),it(3,:),1);

% average the y-intercepts and make them all the same
b = mean(p(:,2)) % display this to see the value
p(:,2) = b;

% plot the straight lines
plot(xvals,polyval(p(1,:),xvals),'k-');
plot(xvals,polyval(p(2,:),xvals),'k-');
plot(xvals,polyval(p(3,:),xvals),'k-');

% set some plot properties (need to do last)
set(gca,'FontSize',14);
legend(ph,'location','northwest');

% plot d(it)/d(CL), the slope, vs h (xcg/c) (see fig 2.21 in book)
% don't have a value for c (chord len), so just use xcg directly
p(4,:) = polyfit(xcg,p(:,1),1);

figure;
plot(xcgvals,polyval(p(4,:),xcgvals),'k-');
ylim([-1 inf]);
hold on; grid on;
ph2(1) = plot(xcg(1),p(1,1),'ko','DisplayName','X_{cg} 2.385m');
ph2(2) = plot(xcg(2),p(2,1),'ks','DisplayName','X_{cg} 2.205m');
ph2(3) = plot(xcg(3),p(3,1),'kd','DisplayName','X_{cg} 2.043m');
ylabel('di_t/dC_L');
xlabel('X_{cg} (m)');
set(gca,'FontSize',14);
legend(ph2,'location','northeast');

% x-intercept = -b/m (y-intercept / slope)
-p(4,2)/p(4,1) % display this to see the x-intercept

