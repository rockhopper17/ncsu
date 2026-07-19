function mySSL
% display a set of standard sea level (SSL) values in either English or Metric units

% string array with atmospheric conditions
atmConditions = ["Pressure","Temperature","Gravity Constant"];

% prompt user for which set of values to display
u = menu('Choose desired units','English','Metric');

switch u
	case 1
		% English values and units
		vals = [14.696, 518.67, 32.174];
		units = ["psi", "R", "ft/s^2"];
	case 2
		% Metric values and units
		vals = [101.325, 288.15, 9.807];
		units = ["kPa", "K", "m/s^2"];
	otherwise
		disp('no choice made');
		return;
end

% print the results of the menu selection
fprintf('Standard Sea Level (SSL) Atmospheric Conditions:\n');
fprintf('%s = %.3f %s\n',[atmConditions;vals;units]);

end
