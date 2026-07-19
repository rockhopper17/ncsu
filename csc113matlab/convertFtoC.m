function [F,C] = convertFtoC(tmin, tmax)
% Converts a range of Fahrenheit temps to Celsius temps
%	Inputs:	tmin - min degrees in f
%			tmax - max degrees in F
%	Output:	F = array with F temps
%			C = array with C temps

% create the Fahrenheit and Celsius arrays
F = tmin:tmax;
C = (F - 32) .* (5/9);

end
