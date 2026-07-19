function [drdt_return] = hw2p1states(t,r)
%% Initial return vector to zero

drdt_return = zeros(6,1);

%% Put position, velocity components into easier nomenclature

rx = r(1);
ry = r(2);
rz = r(3);

vx = r(4);
vy = r(5);
vz = r(6);

%% Define absolute distance between points

r12 = sqrt(rx^2+ry^2+rz^2);

%% Determine accelerations

ax = -398600*(rx)/(r12^3);
ay = -398600*(ry)/(r12^3);
az = -398600*(rz)/(r12^3);

%% Build return data

drdt_return = [vx; vy; vz; ax; ay; az];

end
