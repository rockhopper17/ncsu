% **************************************************************************** %
% MAE 467 Space Flight - Chp 2 Orbits
% **************************************************************************** %

% clear all vars and plots
close all; clear all; clc;

% ex 2.4: plot speed v and period T for satellite in LEO at altitude z
v = @(z) sqrt(398600 ./ (6378 + z));
T = @(z) (2*pi / sqrt(398600)) .* (6378 + z).^(3/2) / 60; % / 60 for sec -> min

% LEO is 150 - 1000 km
altrange = [150 1000];

% plot veloctiy vs altitude
subplot(2,1,1);
fplot(v, altrange);
title('LEO velocity vs altitude');
ylabel('velocity [km/s]');
xlabel('altitude [km]');
grid on;

% plot period vs altitude
subplot(2,1,2);
fplot(T, altrange);
title('LEO orbital period vs altitude');
ylabel('period [min]');
xlabel('altitude [km]');
grid on;

% **************************************************************************** %
% mapping toolbox
% https://www.mathworks.com/help/map/coordinates-geodesy-and-projections.html

E = wgs84Ellipsoid('km')
	%referenceEllipsoid with defining properties:

					 %Code: 7030
					 %Name: 'World Geodetic System 1984'
			   %LengthUnit: 'kilometer'
			%SemimajorAxis: 6378.137
			%SemiminorAxis: 6356.75231424518
		%InverseFlattening: 298.257223563
			 %Eccentricity: 0.0818191908426215

	  %and additional properties:

		%Flattening
		%ThirdFlattening
		%MeanRadius
		%SurfaceArea
		%Volume
