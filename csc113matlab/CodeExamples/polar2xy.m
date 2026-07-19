%%

function [x, y] = polar2xy(r,theta)
%polar2xy converts polar to cartesian coordinates
%   Inputs: polar coordinates:  r (radius), theta (in degrees).
%   Returns: (x,y) are the Cartesian coordinates
x= r.*cosd(theta);
y= r.*sind(theta);
end
