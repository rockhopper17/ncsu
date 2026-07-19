close all; clear all; clc;

% material properties for carbon (as4) / epoxy (3501-6)
E1 = 147e9;
E2 = 10.3e9;
G12 = 7.0e9;
nu12 = 0.27;
t = 0.0005; % 0.5mm = 0.0005m

% force and moment from applied loads
Nx = -1973; % N/m
Ny = -1973;
Ns = 364;
Mx = -157;  % Nm/m
My = 849;
Ms = -849;

S(1,:) = [1/E1 -nu12/E1 0];
S(2,:) = [-nu12/E1 1/E2 0];
S(3,:) = [0 0 1/G12];

% calculate C matrix
C = inv(S)

% calculate the Cbar matrix for each possible orientation (+45,-45,90 degrees)
% 	original C = 0 degrees
for i = 1:3
	if i == 1
		theta = 45;
	elseif i == 2
		theta = -45;
	else
		theta = 90;
	end
	
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

	if i == 1
		CP45 = Cbar
	elseif i == 2
		CN45 = Cbar
	else
		C90 = Cbar
	end
	
end

% iterate each layup and perform analysis
% layups: 1 = unidirectional, 2 = cross-ply, 3 = angle-ply
for layup = 1:3

% calculate ABD matrices
for i = 1:3
	for j = 1:3
		if layup == 1
			A(i,j) = C(i,j)*t + C(i,j)*t + C(i,j)*t;
			B(i,j) = 0.5*(C(i,j)*((-.5*t)^2-(-1.5*t)^2) + C(i,j)*((1.5*t)^2-(.5*t)^2));
			D(i,j) = (1/3)*(C(i,j)*((-.5*t)^3-(-1.5*t)^3) +...
				C(i,j)*((.5*t)^3-(-.5*t)^3) + C(i,j)*((1.5*t)^3-(.5*t)^3));
		elseif layup == 2
			A(i,j) = C(i,j)*t + C90(i,j)*t + C(i,j)*t;
			B(i,j) = 0.5*(C(i,j)*((-.5*t)^2-(-1.5*t)^2) + C(i,j)*((1.5*t)^2-(.5*t)^2));
			D(i,j) = (1/3)*(C(i,j)*((-.5*t)^3-(-1.5*t)^3) +...
				C90(i,j)*((.5*t)^3-(-.5*t)^3) + C(i,j)*((1.5*t)^3-(.5*t)^3));
		else
			A(i,j) = C(i,j)*t + CP45(i,j)*t + CN45(i,j)*t;
			B(i,j) = 0.5*(C(i,j)*((-.5*t)^2-(-1.5*t)^2) + CN45(i,j)*((1.5*t)^2-(.5*t)^2));
			D(i,j) = (1/3)*(C(i,j)*((-.5*t)^3-(-1.5*t)^3) +...
				CP45(i,j)*((.5*t)^3-(-.5*t)^3) + CN45(i,j)*((1.5*t)^3-(.5*t)^3));
		end
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

figure;
plot([-1.5*t 1.5*t],[S0(1) S3(1)],'LineWidth',2,'DisplayName','\epsilon x');
hold on;
plot([-1.5*t 1.5*t],[S0(2) S3(2)],'LineWidth',2,'DisplayName','\epsilon y');
plot([-1.5*t 1.5*t],[S0(3) S3(3)],'LineWidth',2,'DisplayName','\gamma s');
ylabel('strain');
xlabel('z (m)');
set(gca,'FontSize',14);
legend('location','northeast');

ST0a = C*S0;
ST0b = C*S1;
if layup == 1
	ST1a = C*S1;
	ST1b = C*S2;
	ST2a = C*S2;
	ST2b = C*S3;
elseif layup == 2
	ST1a = C90*S1;
	ST1b = C90*S2;
	ST2a = C*S2;
	ST2b = C*S3;
else
	ST1a = CP45*S1;
	ST1b = CP45*S2;
	ST2a = CN45*S2;
	ST2b = CN45*S3;
end

figure;
xvals = [-1.5*t -.5*t -.5*t .5*t .5*t 1.5*t];
plot(xvals,[ST0a(1) ST0b(1) ST1a(1) ST1b(1) ST2a(1) ST2b(1)],'LineWidth',2,'DisplayName','\sigma x');
hold on;
plot(xvals,[ST0a(2) ST0b(2) ST1a(2) ST1b(2) ST2a(2) ST2b(2)],'LineWidth',2,'DisplayName','\sigma y');
plot(xvals,[ST0a(3) ST0b(3) ST1a(3) ST1b(3) ST2a(3) ST2b(3)],'LineWidth',2,'DisplayName','\tau s');
ylabel('stress (N)');
xlabel('z (m)');
set(gca,'FontSize',14);
legend('location','northeast');

end % end layup iteration
