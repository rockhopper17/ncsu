% CSC 113, Introduction to Computing MATLAB
% Approximation of pi

close all          % close all figure windows
figure; shg;       % new figure window
axis equal off     % all axes:  same scale, no display
hold on            % hold all calls to plot on current axes

L= 10;             % length of square (diameter of circle)
R= L/2;            % half length (radius)
axis([-R R -R R])  % axis limits

N= 10000;   % total number of points picked whithin square
M= 0;       % number of points that fall inside the circle
for k= 1:N
    % pick a point inside the square
    x = rand*L-R;
    y = rand*L-R;
    % check to see if it is in the circle
    if sqrt(x^2+y^2)<=R
        pause(0.000000001);
        plot(x,y,'.r')
        M = M + 1;
    else
        pause(0.000000001);
        plot(x,y,'.b')
    end 
end

myPi = (M/N)*4;
err = abs(myPi-pi);
title(sprintf('Pi Estimate = %6.3f  Error = %6.2e', myPi, err),'Fontsize',14)

hold off  % next call to plot will be on new axes
shg       % show figure window
    