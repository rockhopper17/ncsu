% Andrew Navratil
% 2017-09-24
% Section #205
% Homework 4

%% Problem 1: number guessing game

% prompt user to input the min and max values for a range
minval = input('Give the minimum of a range: ');
maxval = input('Give the maximum of a range: ');

% generate a random integer between minval and maxval
val = randi([minval maxval]);

% prompt user to guess an integer in the given range
guess = input('Enter your guess: ');

% loop while user guess is incorrect and keep prompting for a guess
% keep track of how many tries it takes to get correct
% give message for invalid input
n = 1;  % num tries

while guess ~= val
	if rem(guess,1) ~= 0
		guess = input('Invalid input. Enter an integer within the range: ');
	elseif guess < val
		guess = input('Your number was too low.  Enter another guess: ');
	elseif guess > val
		guess = input('Your number was too high.  Enter another guess: ');
	end

	% increment num tries
	n = n + 1;
end

% output the number of tries along with guessed right message
fprintf('You guessed right!\n');
fprintf('It took %d tries to guess the number.\n',n);

%% Problem 2: nested loop for specific output

% recreate the output using nested for loops
% start with num rows
for i = 1:5
	% repeat twice for two columns
	for x = 1:2
		% print asterisks
		for j = 1:i
			fprintf('*');
		end

		% print number
		for k = i:5
			fprintf('%d',(11-2*i));
		end

		% print equal sign
		fprintf('=');
	end

	% after second column go to next line
	fprintf('\n');
end

%% Problem 3: tuition calculation

% set base tuition for calculations
tuition = 3267.5;

% loop the years to predict
for i = 5:5:20
	% loop the next increment of years to update tuition
	for j = 1:5
		tuition = tuition * 1.05;
	end

	% print the year and tuition
	fprintf('In %d, tuition will be $%.2f.\n',2017+i,tuition);
end

%% Problem 4: subplots using for loop

% create figure
figure(1);

% set x range, same for each plot
x = linspace(0,5,100);

% loop subplot number (subplots go row-wise)
for i = 1:6
	% 2x3 subplots, ith plot
	subplot(2,3,i);

	% generate y values and create plot
	y = sin(i.*x);
	plot(x,y);
	
	% use sprintf to include coefficient variable in subplot title
	str = sprintf('sin %d x',i);
	title(str);

	% set x axis to look like pdf: no intervals other than min 0 and max 5
	set(gca,'XLim',[0 5]);
	set(gca,'XTick',(0:5:5));
end

%% Problem 5: Fibonacci sequence

% setup initial numbers in Fibonacci sequence
seq = [0,1];

% prompt user for how many Fibonacci numbers they wish to generate
num = input('How many values in the Fibonacci Sequence would you like to display? ');

% loop for how many numbers the user wants to see
for k = 1:num
	% first print the current number
	fprintf('%d     ',seq(1));

	% now increment the sequence array to setup for next iteration
	seq = [seq(2), seq(1) + seq(2)];
end	
fprintf('\n');

