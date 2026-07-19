function [drdt_return] = two_body(t,r)
%% Initial return vector to zero
global m G
drdt_return = zeros(12,1);

%% Put position, velocity components into easier nomenclature

r1x = r(1);
r1y = r(2);

r2x = r(3);
r2y = r(4);

rGx = r(5);
rGy = r(6);

v1x = r(7);
v1y = r(8);

v2x = r(9);
v2y = r(10);

vGx = r(11);
vGy = r(12);

%% Define absolute distance between points

r12 = sqrt((r2x-r1x)^2+(r2y-r1y)^2);

%% Determine accelerations

a1x = G*m(2)*(r2x-r1x)/(r12^3);
a1y = G*m(2)*(r2y-r1y)/(r12^3);

a2x = -G*m(1)*(r2x-r1x)/(r12^3);
a2y = -G*m(1)*(r2y-r1y)/(r12^3);

aGx = 0;
aGy = 0;

%% Build return data

drdt_return = [v1x; v1y; v2x; v2y; vGx; vGy; a1x; a1y; a2x; a2y; aGx; aGy];

end
