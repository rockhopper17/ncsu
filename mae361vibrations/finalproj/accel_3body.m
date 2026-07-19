% ˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜
function dfdt = accel_3body(t,f)
% ˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜
%
% This function evaluates the acceleration of each member of a
% planar 3-body system at time t from their positions and
% velocities at that time.
%
% G - gravitational constant
% (kmˆ3/kg/sˆ2)
% m - vector [m1, m2, m3] containing
% the masses m1, m2, m3 of the
% three bodies (kg)
% r1x, r1y; r2x, r2y; r3x, r3y - components of the position
% vectors of each mass (km)
% v1x, v1y; v2x, v2y; v3x, v3y - components of the velocity
% vectors of each mass (km/s)
% a1x, a1y; a2x, a2y; a3x, a3y - components of the acceleration
% vectors of each mass (km/sˆ2)
% rGx, rGy; vGx, vGy; aGx, aGy - components of the position,
% velocity and acceleration of
% the center of mass
% t - time (s)
% f - column vector containing the
% position and velocity
% components of the three
% masses and the center of
% mass at time t
% dfdt - column vector containing the
% velocity and acceleration
% components of the three
% masses and the center of
% mass at time t
%
% User M-functions required: none
% ------------------------------------------------------------
global G m
%...Initialize the 16 by 1 column vector dfdt:
dfdt = zeros(16,1);
%...For ease of reading the code, assign each component of f
%...to a mnemonic variable:
r1x = f( 1);
r1y = f( 2);
r2x = f( 3);
r2y = f( 4);
r3x = f( 5);
r3y = f( 6);
rGx = f( 7);
rGy = f( 8);
v1x = f( 9);
v1y = f(10);
v2x = f(11);
v2y = f(12);
v3x = f(13);
v3y = f(14);
vGx = f(15);
vGy = f(16);
%...Equations C.9:
r12 = norm([r2x - r1x, r2y - r1y])^3;
r13 = norm([r3x - r1x, r3y - r1y])^3;
r23 = norm([r3x - r2x, r3y - r2y])^3;
%...Equations C.8:
a1x = G*m(2)*(r2x - r1x)/r12 + G*m(3)*(r3x - r1x)/r13;
a1y = G*m(2)*(r2y - r1y)/r12 + G*m(3)*(r3y - r1y)/r13;
a2x = G*m(1)*(r1x - r2x)/r12 + G*m(3)*(r3x - r2x)/r23;
a2y = G*m(1)*(r1y - r2y)/r12 + G*m(3)*(r3y - r2y)/r23;
a3x = G*m(1)*(r1x - r3x)/r13 + G*m(2)*(r2x - r3x)/r23;
a3y = G*m(1)*(r1y - r3y)/r13 + G*m(2)*(r2y - r3y)/r23;
%...Equation C.5a:
aGx = 0;
aGy = 0;
%...Place the evaluated velocity and acceleration components
%...into the vector dfdt, to be returned to the calling
%...program:
dfdt = [v1x; v1y; ...
v2x; v2y; ...
v3x; v3y; ...
vGx; vGy; ...
a1x; a1y; ...
a2x; a2y; ...
a3x; a3y; ...
aGx; aGy];
% ˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜
