function pstr = plotFormatting()
%  Creates a string to format a plot
%	Inputs: N/A	
%	Outputs: pstr - string with plot formatting information

color = input('What color would you like? ','s');
style = input('Enter plot style (o or *): ','s');

pstr = strcat(color(1),style);

end
