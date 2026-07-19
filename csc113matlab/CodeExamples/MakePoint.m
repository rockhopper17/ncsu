%%

function P = MakePoint(x,y)
%MakePoint creates a Point Structure
%   Inputs: x, y are point coordinates
%   Returns: P, a structure with fields x & y
% 
P = struct('x',x,'y',y);

