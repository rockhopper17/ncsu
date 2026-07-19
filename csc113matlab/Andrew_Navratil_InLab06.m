% Name: Andrew Navratil
% Section: 205
% Date: 2017-10-12
% In-Lab 06

clear all; close all; clc % clear functions
%% Instructor-Guided Portion
%% Problem 1 - Wolfpack Word Search 
% Create a random matrix of letters c through r, then add 'WOLFPACK'.

% Replacing WOLFPACK
wolf = 'WOLFPACK';

% Creating char() matrix: (c=99, r=114)
mat = randi([99 114], 8, 5);
Q = char(mat);   %convert ascii to char

for i = 1:length(wolf)
	Q(i,3) = wolf(i);
end

% Display final search:
disp(Q);


%% Problem 2 - Add Blank Space 
% Create function convertToBlank() to remove underscores and call below.
str = 'They_call_it_a_Royale_with_cheese';
str2 = 'YOU_SHOULD_START_PROJECT_2';

% Calling function:
first = convertToBlank(str);
disp(first);

second = convertToBlank(str2);
disp(second);


%% Problem 3 - I heard you like Cells... 
% Create the given arrays within a larger cell array and perform the
% operations.

% From IL sheet
A = [101 139 189; 22 44 66; 206 407 429];
B = {'Alwin','Casey','Matthew';'Andrew','Charlotte','Brandon';'Andy', ...
    'John-Michael','Raven';'Anna','Jonathan','Seth';'Alper', ...
    'Kevin','Esther'};
C = int8([1;1;3]);

% concatenate data into cell array
sample_cell = {A,B,C};

% a. Extract A from cell array:
cA = sample_cell(1);
dA = sample_cell{1};

% b. Extract your TAs:
devol = sample_cell{2}{2,2};  % uses 2 curly brackets because of cell array

% c. Perform operation:
numer = dA(2,3);
denom = sample_cell{3}(3,1); % indexes into 3rd cell
quotient = numer / denom;
quotient = double(quotient); % converts int8 value to double

% d. Visualize sample_cell:
cellplot(sample_cell);

%% Problem 4 - Data Conversion
% Create the function typeConvert() to store a given variable as different
% data types.

num = -1000;

% Call the function:
cell_array = typeConvert(num);



%% Independent Portion

