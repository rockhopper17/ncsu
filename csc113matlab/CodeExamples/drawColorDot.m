%%

function drawColorDot(x, y, color)
%drawColorDot draws a dot at coordinates(x,y). 
%   Inputs: (x,y) are the Cartesian coordinates
%           color - red if set to 0, otherwise blue.
%   Returns: nothing
if (color == 0)
    plot(x,y,'y.','markersize',20)
else
    plot(x,y,'b.','markersize',20)
end
