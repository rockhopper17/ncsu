function ellipsePlot( xc, yc, a, b)
% plots an ellipse
%	Inputs: xc, yc - coordinates of center
%			a, b - semi-major and semi-minor axis

% create an array of angles
theta = [0:pi/360:2*pi];

% setup the x and y values for the ellipse
x = xc + a .* cos(theta);
y = yc + b .* sin(theta);

% create the plot, showing the ellipse and the center
figure(1);
hold on;
plot(x,y,'r');
plot(xc,yc,'r*');
xlabel('x');
ylabel('y');

end
