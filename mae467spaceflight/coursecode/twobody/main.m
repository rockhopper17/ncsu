clear all

%% Define time vector

t_initial = 0;
t_final = 100;

%% Define masses and gravitational constants
global m G
m = [10 1]; %kg
G = 10; %m^3/kg*s^2

%%%%m = [5 10]; %kg
%%%%G = 10; %m^3/kg*s^2
%% Define intiial position and velocity vectors

r0 = [[0 0]; [5 0]];
v0 = [[0 0]; [3 3]];

%% Initial position and velocity of the center of mass

rG0 = m*r0/sum(m);
vG0 = m*v0/sum(m);

%% Create initial condition column vector

init_cond = [r0(1,:)';r0(2,:)';rG0';v0(1,:)';v0(2,:)';vG0'];

[t,r] = ode45('two_body',[t_initial t_final], init_cond);

%% Plot motion relative to the inertial frame
close all

figure
title('Motion relative to the inertial frame','Fontweight','bold','FontSize',12)
hold on
% x1 vs y1
plot(r(:,1),r(:,2),'r','Linewidth',2.0)
% x2 vs y2
plot(r(:,3),r(:,4),'b','Linewidth',2.0)
% xg vs yg
plot(r(:,5),r(:,6),'k--','Linewidth',2.0)
xlabel('x','Fontweight','bold','FontSize',12);ylabel('y','Fontweight','bold','FontSize',12);
grid on
axis('equal')

%% Motion relative to the center of mass
figure
title('Motion relative to the center of mass','Fontweight','bold','FontSize',12)
hold on
% x1-xg vs y1-yg
plot(r(:,1)-r(:,5),r(:,2)-r(:,6),'r','Linewidth',1.0)
% x2-xg vs y2-yg
plot(r(:,3)-r(:,5),r(:,4)-r(:,6),'b','Linewidth',1.0)
xlabel('x','Fontweight','bold','FontSize',12);ylabel('y','Fontweight','bold','FontSize',12);
grid on
axis('equal')

%% Motion relative to m1
figure
title('Motion relative to m1','Fontweight','bold','FontSize',12)
hold on
% x2-x1 vs y2-y1
plot(r(:,3)-r(:,1),r(:,4)-r(:,1),'b','Linewidth',1.0)
xlabel('x','Fontweight','bold','FontSize',12);ylabel('y','Fontweight','bold','FontSize',12);
grid on
axis('equal')

