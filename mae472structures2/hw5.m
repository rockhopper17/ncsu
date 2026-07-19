close all; clear all; clc;

% properties from #2
E1 = 145.0e9;
E2 = 10.5e9;
G12 = 7.0e9;
nu12 = 0.28;
t = 0.25e-3;
%t = 0.5;

% properties from #3
Nx = 0.6e6;
Ny = -0.3e6;
Ns = 0;
Mx = 0;
My = -0.2e3;
Ms = 0.5e3;

S(1,:) = [1/E1 -nu12/E1 0];
S(2,:) = [-nu12/E1 1/E2 0];
S(3,:) = [0 0 1/G12];

C = inv(S)

theta = 45;
c = cosd(theta);
s = sind(theta);
Cbar(1,1) = C(1,1)*c^4 + C(2,2)*s^4 + (2*C(1,2)+4*C(3,3))*c^2*s^2;
Cbar(1,2) = C(1,2)*(c^4 + s^4) + (C(1,1)+C(2,2)-4*C(3,3))*c^2*s^2;
Cbar(2,2) = C(1,1)*s^4 + C(2,2)*c^4 + (2*C(1,2)+4*C(3,3))*c^2*s^2;
Cbar(1,3) = (C(1,1)-C(1,2)-2*C(3,3))*c^3*s - (C(2,2)-C(1,2)-2*C(3,3))*c*s^3;
Cbar(2,3) = (C(1,1)-C(1,2)-2*C(3,3))*c*s^3 - (C(2,2)-C(1,2)-2*C(3,3))*c^3*s;
Cbar(3,3) = (C(1,1)+C(2,2)-2*C(1,2)-2*C(3,3))*c^2*s^2 + C(3,3)*(c^4+s^4);
Cbar(2,1) = Cbar(1,2);
Cbar(3,1) = Cbar(1,3);
Cbar(3,2) = Cbar(2,3);
CP45 = Cbar;

theta = -45;
c = cosd(theta);
s = sind(theta);
Cbar(1,1) = C(1,1)*c^4 + C(2,2)*s^4 + (2*C(1,2)+4*C(3,3))*c^2*s^2;
Cbar(1,2) = C(1,2)*(c^4 + s^4) + (C(1,1)+C(2,2)-4*C(3,3))*c^2*s^2;
Cbar(2,2) = C(1,1)*s^4 + C(2,2)*c^4 + (2*C(1,2)+4*C(3,3))*c^2*s^2;
Cbar(1,3) = (C(1,1)-C(1,2)-2*C(3,3))*c^3*s - (C(2,2)-C(1,2)-2*C(3,3))*c*s^3;
Cbar(2,3) = (C(1,1)-C(1,2)-2*C(3,3))*c*s^3 - (C(2,2)-C(1,2)-2*C(3,3))*c^3*s;
Cbar(3,3) = (C(1,1)+C(2,2)-2*C(1,2)-2*C(3,3))*c^2*s^2 + C(3,3)*(c^4+s^4);
Cbar(2,1) = Cbar(1,2);
Cbar(3,1) = Cbar(1,3);
Cbar(3,2) = Cbar(2,3);
CN45 = Cbar;

for i = 1:3
	for j = 1:3
		A(i,j) = C(i,j)*t + CP45(i,j)*t + CN45(i,j)*t;
		B(i,j) = 0.5*(C(i,j)*((-.5*t)^2-(-1.5*t)^2) + CN45(i,j)*((1.5*t)^2-(.5*t)^2));
		D(i,j) = (1/3)*(C(i,j)*((-.5*t)^3-(-1.5*t)^3) +...
		   	CP45(i,j)*((.5*t)^3-(-.5*t)^3) + CN45(i,j)*((1.5*t)^3-(.5*t)^3));
	end
end

A
B
D

F = inv([A B;B D]);

SK = F*[Nx Ny Ns Mx My Ms]';

S0 = SK(1:3) - 1.5*t*SK(4:6);
S1 = SK(1:3) - 0.5*t*SK(4:6);
S2 = SK(1:3) + 0.5*t*SK(4:6);
S3 = SK(1:3) + 1.5*t*SK(4:6);

plot([-1.5*t 1.5*t],[S0(1) S3(1)],'LineWidth',2,'DisplayName','\epsilon x');
hold on;
plot([-1.5*t 1.5*t],[S0(2) S3(2)],'LineWidth',2,'DisplayName','\epsilon y');
plot([-1.5*t 1.5*t],[S0(3) S3(3)],'LineWidth',2,'DisplayName','\gamma s');
ylabel('strain');
xlabel('z (m)');
set(gca,'FontSize',14);
legend('location','southeast');

ST0a = C*S0;
ST0b = C*S1;
ST1a = CP45*S1;
ST1b = CP45*S2;
ST2a = CN45*S2;
ST2b = CN45*S3;

figure;
xvals = [-1.5*t -.5*t -.5*t .5*t .5*t 1.5*t];
plot(xvals,[ST0a(1) ST0b(1) ST1a(1) ST1b(1) ST2a(1) ST2b(1)],'LineWidth',2,'DisplayName','\sigma x');
hold on;
plot(xvals,[ST0a(2) ST0b(2) ST1a(2) ST1b(2) ST2a(2) ST2b(2)],'LineWidth',2,'DisplayName','\sigma y');
plot(xvals,[ST0a(3) ST0b(3) ST1a(3) ST1b(3) ST2a(3) ST2b(3)],'LineWidth',2,'DisplayName','\tau s');
ylabel('stress (N)');
xlabel('z (m)');
set(gca,'FontSize',14);
legend('location','northwest');

