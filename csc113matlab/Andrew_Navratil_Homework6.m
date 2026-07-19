% Andrew Navratil
% 2017-10-19
% Section #205
% Homework 6

clear;close all;clc;

%% call to isPal
a = isPal('Reward a drawer');
b = isPal('this is not one');
c = isPal('Rats live on no evil star');

%% cell array with metals table

% store each name in a cell array
names = {'Aluminum';'Copper';'Iron';'Molybdenum';'Cobalt';'Vanadium'};

% store each symbol in a padded character array
symbols = char('Al','Cu','Fe','Mo','Co','V');

% store the atomic number in an unsigned 8-bit integer array
atomicnum = uint8([13;29;26;42;27;23]);

% store the weight in a single-precision array
atomicwgt = single([26.98;63.55;55.85;95.94;58.93;50.94]);

% store the density in a double-precision array
density = double([2.71;8.94;7.87;10.22;8.9;6.0]);

% store the crystal structure in a padded character array
crystal = char('FCC','FCC','BCC','BCC','HCP','BCC');

% concatenate all the data arrays into a single cell array
elementData = {names,symbols,atomicnum,atomicwgt,density,crystal};

% extract the name, atomic weight, and structure of Cobalt
cobaltName = elementData{1}{5};
cobaltAtomicWeight = elementData{4}(5);
cobaltStructure = elementData{6}(5,:);

% extract the names of all the elements
%   note: this will still be another cell array, must use curly braces again
%         to pull out the actual names as strings
allnames = elementData{1};
% to get a name do: allnames{5} to get 'Cobalt'

% extract the average atomic weight of all elements
avgAtomicWeight = mean(elementData{4});

%% call dateNum2Str

dateNum2Str([10 23 2077]);

%% camelCase a variable name

% loop to validate the user's input for a variable name conversion
while(true)
	var = input('Input variable name: ','s');

	if isstrprop(var(1),'digit')
		% input starts with a number, prompt again
		disp('Error: variables must start with a letter.');
		continue;
	elseif (sum(isletter(var)) + sum(isspace(var)) + sum(isstrprop(var,'digit')) ) < length(var)
		% input contains something other than letters, numbers, and spaces
		disp('Error: variables must contain only letters, numbers, and spaces');
		continue;
	else
		% we are good, continue to conversion
		break;
	end
end

% first convert all the letters to lower case
var = lower(var);

% initialize a new variale for holding the converted name
% start with first letter of variable
varCamelCase = var(1);

% loop to reformat the variable name in camelCase without spaces
%   we can start at index 2 since we know it doesn't start with a number
for i = 2:length(var)
	if ( isspace(var(i-1)) && isletter(var(i)) )
		varCamelCase = [varCamelCase,upper(var(i))];
	elseif ~isspace(var(i))
		varCamelCase = [varCamelCase,var(i)];
	end
end

% output by just calling variable to look like the HW pdf
varCamelCase

%% call cryptogram

cryptogram('Go Wolfpack!');
cryptogram('Bye Gottfried!');
cryptogram('Mars or Bust!!!!!');

