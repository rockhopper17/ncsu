% Set up figure window
close all;  clc; 

c = input('Number of rings: ');
d = input('Number of dots in each ring: ');

figure;  shg;
axis equal off; axis([-c c -c c]); hold on; 

%ring by ring
for rRing= 1:c
    % dot by dot
    for count= 1:d
        %figure out where to place the dots
        theta= randDouble(0, 360); %draw random angle
        %draw random radius between circles 
        radius= randDouble(rRing-1, rRing);
        
        %convert polar to cartesian
        [x, y]= polar2xy(radius, theta);
        
        %odd rings are blue, even are red
        drawColorDot(x, y, rem(rRing,2));
        
        pause(0.01);
    end
end

hold off