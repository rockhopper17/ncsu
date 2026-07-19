%%

function DrawLine(P,Q,c)
% DrawLine draws a line segment connecting P and Q in color c 
%   Inputs: P and Q are points (structures).
%           c is a string specifying the color
plot([P.x Q.x],[P.y Q.y],c, 'LineWidth',2);
