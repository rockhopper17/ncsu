% ˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜
% threebody
% ˜˜˜˜˜˜˜˜˜
%
% This program presents the graphical solution of the motion of
% three bodies in the plane for data provided in the input
% definitions below.
%
% G - gravitational constant (kmˆ3/kg/sˆ2)
% t_initial, t_final - initial and final times (s)
% m - vector [m1, m2, m3] containing the
% masses m1, m2, m3 of the three
% bodies (kg)
% r0 - 3 by 2 matrix each row of which
% contains the initial x and y components
% of the position vector of the
% respective mass (km)
% v0 - 3 by 2 matrix each row of which contains
% the initial x and y components of the
% velocity of the respective mass (km/s)
% rG0 - vector containing the initial x and y
% components of the center of mass (km)
% vG0 - vector containing the initial x and y
% components of the velocity of the
% center of mass (km/s)
% f0 - column vector of the initial conditions
% passed to the Runge-Kutta solver ode45
% t - column vector of times at which the
% solution was computed
% f - matrix the columns of which contain the
% position and velocity components
% evaluated at the times t(:):
% f(:,1) , f(:,2) = x1(:), y1(:)
% f(:,3) , f(:,4) = x2(:), y2(:)
% f(:,5) , f(:,6) = x3(:), y3(:)
% f(:,7) , f(:,8) = xG(:), yG(:)
%
% f(:,9) , f(:,10) = v1x(:), v1y(:)
% f(:,11), f(:,12) = v2x(:), v2y(:)
% f(:,13), f(:,14) = v3x(:), v3y(:)
% f(:,15), f(:,16) = vGx(:), vGy(:)
%
% User M-function required: accel_3body
% ------------------------------------------------------------
clear
global G m
G = 6.67259e-20;
%...Input data:
t_initial = 0; t_final = 67000;
m = [1.e29 1.e29 1.e29];
r0 = [[ 0 0]
[300000 0]
[600000 0]];
v0 = [[ 0 0]
[250 250]
[ 0 0]];
%...
%...Initial position and velocity of center of mass:
rG0 = m*r0/sum(m);
vG0 = m*v0/sum(m);
%...Initial conditions must be passed to ode45 in a column
%...vector:
f0 = [r0(1,:)'; r0(2,:)'; r0(3,:)'; rG0'; ...
v0(1,:)'; v0(2,:)'; v0(3,:)'; vG0']
%...Pass the initial conditions and time interval to ode45,
%...which calculates the position and velocity at discrete
%...times t, returning the solution in the column vector f.
%...ode45 uses the m-function 'accel_3body' to evaluate the
%...acceleration at each integration time step.
[t,f] = ode45('accel_3body', [t_initial t_final], f0);
close all
%...Plot the motion relative to the inertial frame
%...(Figure 2.5):
figure
title('Figure 2.5: Motion relative to the inertial frame', ...
'Fontweight', 'bold', 'FontSize', 12)
hold on
%...x1 vs y1:
plot(f(:,1), f(:,2), 'r', 'LineWidth', 0.5)
%...x2 vs y2:
plot(f(:,3), f(:,4), 'g', 'LineWidth', 1.0)
%...x3 vs y3:
plot(f(:,5), f(:,6), 'b', 'LineWidth', 1.5)
%...xG vs yG:
plot(f(:,7), f(:,8), '--k', 'LineWidth', 0.25)
xlabel('X'); ylabel('Y')
grid on
axis('equal')
%...Plot the motion relative to the center of mass
%...(Figure 2.6):
figure
title('Figure 2.6: Motion relative to the center of mass', ...
'Fontweight', 'bold', 'FontSize', 12)
hold on
%...(x1 - xG) vs (y1 - yG):
plot(f(:,1) - f(:,7), f(:,2) - f(:,8), 'r', 'LineWidth', 0.5)
%...(x2 - xG) vs (y2 - yG):
plot(f(:,3) - f(:,7), f(:,4) - f(:,8), '--g', 'LineWidth', 1.0)
%...(x3 - xG) vs (y3 - yG):
plot(f(:,5) - f(:,7), f(:,6) - f(:,8), 'b', 'LineWidth', 1.5)
xlabel('X'); ylabel('Y')
grid on
axis('equal')
% ˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜
