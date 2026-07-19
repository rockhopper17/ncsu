%%

function d = calcDistance( P, Q)
%calcDistance calculates the distance between two points
%   Inputs: P and Q are point structures
%   Returns: d the distance between P & Q.
d = sqrt((P.x-Q.x)^2 +(P.y-Q.y)^2);
end

