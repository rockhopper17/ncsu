%CSC 113
%Creates a Pick-Up Sticks Figure
close all; hold on
s = 'rgbmcy'; %possible collors
for k=1:75 %75 lines drawn
    P = MakePoint(rand,rand); %random point
    Q = MakePoint(rand,rand); %random point
    c = s(ceil(6*rand)); %random color from the possible colors
    DrawLine(P,Q,c); %draw a line in the chosen color
    pause(0.15);
end 
set(gca,'Color','k');  %set the background to black
shg %bring the figure window to the front