%Lina Battestili
function [ p, a] = calcRectangle( w, l )
%This function calculates the area and paramenter
%of a rectangle
% Inputs: w is the width and l is the length
% Outputs: p is the parameter and a is the area

%veryfy both sides are postive
if (w > 0) || (l > 0)    
    p = 2*w + 2*l;
    a = w*w;
else        
    beep;
    disp ('The width and length must be positive!')
    p=-1; a=-1;
end

end

