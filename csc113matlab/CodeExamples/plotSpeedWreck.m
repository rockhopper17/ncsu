%%

function plotSpeedWreck( d )
%plots the speed of the Rambling Wreck car over time for 
%a specific test run based on the vector d
%
%Input: d row vector of real numbers, containing the displacement 
%         of the car from the origin at that second.  
%         The first element is the displacement at the 0th second, 
%         the second  element is the displacement at the 1st second, etc.

%determine the number of time points
t = 0:length(d)-1;
%numerically estimate the speed
v = diff(d) ./ diff(t);
%plot it
h = plot(t(1:(end-1)), v);
h.LineWidth = 2;
h.Color = 'r';
h.Marker = 'o';
h.MarkerSize = 15;
title('Speed of Wrambling Wreck Car');
xlabel('seconds');
grid on
end

