%%

function vol = calcVolHollowSphere( R, r )
%calcVolHollowSphere calculates the volume of a hollow sphere
%   Inputs: R the radius of the outer sphere
%           r the radius of the inner sphere
%  Returns: vol, the volume of hollow sphere

vol = (4/3)*pi*(R^3 - r^3);

end

