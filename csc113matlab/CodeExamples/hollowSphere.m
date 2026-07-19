clear; clc;

% get input from user
R = input('Outer radius of the sphere: ');
r = input('Inner radius of the sphere: ');

% calculate the volume of the hollow sphere
v = calcVolHollowSphere(R,r);
fprintf('The volume of a hollow sphere with\n');
fprintf('Outer Radius=%.2f, Inner Radius=%.2f is %.2f\n', R, r, v); 