% Andrew Navratil
% MAE 253 Spring 2018
% Lab 1 Pressure Transducer Calculation
% Due 2018-02-05

% import dat files from wed session 1
% Column definitions in the provided data files:
%	P_transducer (psf) | h_manometer (inches) | I_sensor (mA) | T_transducer (degree F)
datainc = load('data/Lab-1_Increasing-Velocity_Wednesday-Session-1_20180124.dat');
datadec = load('data/Lab-1_Decreasing-Velocity_Wednesday-Session-1_20180124.dat');

% constants
hoffset = 0.8;		% in (h_manometer offset based on zero reading from file)
in_to_m = 0.0254;	% 0.0254 m / 1 in
rhowater = 997.71;  % kg/m^3
g = 9.8;			% m/s^2

%pman = data(
