% Andrew Navratil
% MAE 456 CFD
% Project 1: Numerical analysis of linear wave equation
% Due 2019-03-08

% clear all vars and plots
close all; clear all; clc;

% case 1: backward spatial diff, forward time, explicit
for nu = [0.4 1.0]
	% call cfd function in mex c code
	% [mesh, sln] = cfd(cfl num, case num)
	[x, u] = cfd(nu, 1);

	% plot all together
	plot(x,u,'DisplayName',['CFL ' num2str(nu)]);
	hold on; grid on;
end
title('Backward spatial difference, explicit integration','FontSize',16);
ylabel('Solution Value u(x_i)','FontSize',14);
xlabel('Spatial Coordinate x_i','FontSize',14);
axis([0 1 -0.2 1.2]);
legend('Location','Northwest','FontSize',14);
set(gca,'FontSize',14);

% case 1: unstable CFL = 1.3
figure;
nu = 1.3;
[x, u] = cfd(nu, 1);
plot(x,u,'DisplayName',['CFL ' num2str(nu)]);
hold on; grid on;
title('Backward spatial difference, explicit integration: unstable','FontSize',16);
ylabel('Solution Value u(x_i)','FontSize',14);
xlabel('Spatial Coordinate x_i','FontSize',14);
legend('Location','Northwest','FontSize',14);
set(gca,'FontSize',14);

% case 2: central spatial diff, forward time, explicit
% all unstable, just show one very small CFL
figure;
nu = 0.0001;
[x, u] = cfd(nu, 2);
plot(x,u,'DisplayName',['CFL ' num2str(nu)]);
hold on; grid on;
title('Central spatial difference, explicit integration','FontSize',16);
ylabel('Solution Value u(x_i)','FontSize',14);
xlabel('Spatial Coordinate x_i','FontSize',14);
legend('Location','Northwest','FontSize',14);
set(gca,'FontSize',14);

% case 3: central spatial diff, implicit
figure;
for nu = [0.4 1.0 1.3]
	[x, u] = cfd(nu, 3);
	plot(x,u,'DisplayName',['CFL ' num2str(nu)]);
	hold on; grid on;
end
title('Central spatial difference, implicit integration','FontSize',16);
%title('Central spatial difference, implicit integration, dx = 0.0001','FontSize',16);
ylabel('Solution Value u(x_i)','FontSize',14);
xlabel('Spatial Coordinate x_i','FontSize',14);
legend('Location','Northwest','FontSize',14);
set(gca,'FontSize',14);

% case 4: lax-wendroff scheme
figure;
for nu = [0.4 1.0]
	[x, u] = cfd(nu, 4);
	plot(x,u,'DisplayName',['CFL ' num2str(nu)]);
	hold on; grid on;
end
title('Lax-Wendroff scheme, explicit integration','FontSize',16);
ylabel('Solution Value u(x_i)','FontSize',14);
xlabel('Spatial Coordinate x_i','FontSize',14);
legend('Location','Northwest','FontSize',14);
set(gca,'FontSize',14);

% case 4: unstable CFL = 1.3
figure;
nu = 1.3;
[x, u] = cfd(nu, 1);
plot(x,u,'DisplayName',['CFL ' num2str(nu)]);
hold on; grid on;
title('Lax-Wendroff scheme, explicit integration: unstable','FontSize',16);
ylabel('Solution Value u(x_i)','FontSize',14);
xlabel('Spatial Coordinate x_i','FontSize',14);
legend('Location','Northwest','FontSize',14);
set(gca,'FontSize',14);

