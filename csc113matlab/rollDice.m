function [d1, d2] = rollDice(n)
% Rolls two n-sided dice and returns their values as separate variables
%	Inputs: 	n - number of sides on the dice
%	Outputs: 	d1 - results of the first dice
%				d2 - results of the second dice

d1 = randi(n);
d2 = randi(n);

end
