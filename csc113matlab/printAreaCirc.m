function printAreaCirc(r)
% Function creates table of circumference and area 
%	Inputs: r - radius (could be a vector) 
%	Outputs: N/A 

% Calculates circumference
circ = 2*pi*r;

% Calculates area
area = pi*r.^2;

% Displays the answers
info = [r; area; circ];
fprintf('Radius\tArea\tCircumference\n');
fprintf('%3d%10.2f%10.2f\n',info);

end
