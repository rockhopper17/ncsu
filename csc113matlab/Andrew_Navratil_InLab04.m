% Name Andrew Navratil
% Date 2017-09-14
% Section #205
% In-Lab 4

clear all; close all; clc % clear functions
%% Instructor-Guided Portion
%% Problem 1 - Nested Loops
% Re-create the printed text using nested for loops.
for rows = 1:5 % initialize first for loop with row #
	for col = 1:2
		for stars = 1:rows
			fprintf('*');
		end
		for dots = 1:6-rows
			fprintf('.');
		end
		fprintf('%d',rows-1);
	end
	fprintf('\n');
end



%% Problem 2 - Factoring
% Prompt the user for an integer, then display the smallest factor.

% Prompt user for input (assumed positive whole number):
num = input('Enter an integer: ');
factor = 2; %initialize variable for smallest factor

% Use a single while loop to find smallest factor:
while rem(num, factor) ~= 0
	factor = factor + 1;
end

% Print smallest factor to command window:
fprintf('The smallest factor of %d is %d.\n',num,factor);


%% Problem 3 - Taylor Series Approximation
% Approximate cos(x) using a Taylor series, then compare.

% Prompt user for input x (in radians):
rad = input(['Enter a value in radians to evaluate cos(x) using Taylor Series'...
	' approximation: ']);

% Compute actual value of cos(x), use while loops to approximate using
% Taylor series. Stop loop when within +/-0.001 of actual value.
approx = 1;         % variable to hold Tayler Series approx
actual = cos(rad);  % actual value of cosine
expfact = 2;        % initiliaze exponent of x 
elem = 1;           % initiliaz element counter

% loop will run while approx is not within tolerance
while abs(actual - approx) > .001
	% start by incrementing element count since we already have first term of 1
	elem = elem + 1;
	
	if rem(elem,2) == 0
		pos = -1;
	else
		pos = 1;
	end

	% perform the next operation in the taylor series
	approx = approx + (pos * ((rad^expfact) / factorial(expfact)) );
	
	% update incremental counters
	expfact = expfact + 2;
	
end

% Print results to command window, including number of loop iterations:
fprintf('Actual value: %.3f\n', actual);
fprintf('Approximation: %.3f\n', approx);
fprintf('It took %d terms to approximate cos(x).\n', elem);


%% Independent Portion

%% For Loop 001
%% Data section
% Do not duplicate this section
m = 1;
n = 1;
%% Code section% preallocate a matrix for A 
A = zeros(m,n);

% this was not needed!!!
% if it's a 1x1, must handle outside of loop
%if (size(A) == 1)
	%A(m,n) = m + n;
%end

% insert loop code here
for i = 1:m
    for j = 1:n
        A(i,j) = i + j;
    end
end

%% For Loop 002
%% Data section
% Do not duplicate this section
V = randi(5,1,25);
%% Code section% write code that only needs to be run once outside the loop

% initialize count variable
c = 0;

% create a for loop to check each element
for i=1:length(V)

% create an if statement to check if the selected element is divisible by 3
  if rem(V(i),3) == 0

    % update a count for numbers divisible by 3
	c = c + 1;

  end % if statement

end % for loop

%% While Loop 001
% Make sure to assign all variables used within loops
n = 1;
actual = exp(-1);
approx = (1 - (n^(-1)))^n;
tolerance = 0.0001;

% create a while loop to check if the approximation is within the specified tolerance
while abs(actual - approx) > tolerance
% update values within the loop
	n = n + 1;
	approx = (1 - (n^(-1)))^n;
end

%% Vectorizing 001
tic
loop_sum = [];
for n = 1:9999
loop_sum(n) = ( (-1)^(n+1) * n^(-1));
end
loop_sum = sum(loop_sum);
loop_time = toc;

tic
n = 1:9999                    
vec_sum = sum( (-1).^(n+1) .* n.^(-1) );
vec_time = toc;       % do not remove this line
