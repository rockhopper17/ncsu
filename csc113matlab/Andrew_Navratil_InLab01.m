% Name Andrew Navratil
% Date 8/24/2017
% Section #205
% In-Lab 1

clear all; close all; clc %clear functions
%% Instructor-Guided Portion
%% Problem 1 - Errors
% The following comments may have errors. 
% Add comments to explain the errors, 
% then write the repaired command after the comment.

% a. ayy = (15+6)*16+3(6+9)
% the code is missing an asterisk for multiplication, must be explicit
ayy = (15+6)*16+3*(6+9);

% b. B = mean(1,17,43)
% mean takes only one paramter
x = [1, 17, 43];
B = mean(x);

% c. 3c = 3:12:1
% 3c is not a valid variable name, they can't start with a number
% if we want to increment from 3 to 12, we must switch the 1 and 12
c = 3:1:12;

% d. dee = atan(linspace([1,15,6]))
% linspace requires 2 or 3 parameters, no brackets
dee = atan(linspace(1,15,6));

% e. for = logspace(1,15,6)
% for is a keyword, should not be used as a variable name
f = logspace(1,15,6);

%% Problem 2 - Basic Functions
% Create variables x, y, and z
% Assign unique integer values so that x < y < z
% Perform operations:

x = 1; y = 2; z = 5;

% a. Find the product of all three variables:
a = prod([x, y, z]);

% b. Find the difference of x minus y, then divide by x minus z:
b = (x - y) / (x - z);

% c. Create a 3x1 matrix with x, y, and z on the top, middle, and bottom rows:
c = [x;y;z];

% d. Create a matrix from y to z using x amount of values using linspace:
d = linspace(y,z,x);

% e. Create a matrix from y to z in intervals of x:
e = y:x:z;


%% Problem 3 - Matrix Manipulation and formatting
% Create the matrix, mat. 
% Using mat, create mat2-mat4 using matrix manipulation commands.
% List and perform operations:
mat = magic(4);

% a. swap the first and fourth columns of mat, store as mat2
mat2 = [mat(:,4), mat(:,2:3), mat(:,1)];

% b. add first 2 rows of mat to end of mat2, store as mat3
mat3 = [mat2;mat(1:2,:)];

% c. add 2 to each element in mat3, then multiply by scalar value 3, store
% as mat 4
mat4 = (mat3 + 2) * 3;

% d. determine and store the num of rows and columns for mat4; transpose,
% find rows and columns again and compare
mat5 = mat4';
[numRowsMat4, numColsMat4] = size(mat4);
[numRowsMat5, numColsMat5] = size(mat5);

% e. find mean value in each row of mat4, store as mean4
mean4 = mean(mat4');

% f. find max value in each column and row it occurs for mat4
[max4val, max4row] = max(mat4);

%% Independent Portion - Submit in Cody and Copy Solutions Below

% Use the variables given, write the code for each section to the right of the '=' sign
% Use built in commands and functions to accomplish these tasks efficiently.

% %% Cody - Basic Operations 001
% 
% % row vector from 1 to 15
% A = [1:15];
% 
% % number of elements in vector A
% B = prod(size(A));
% 
% % average value of vector A
% C = mean(A);
% 
% % inverse cosine of vector A (degrees)
% D = acosd(A);
% 
% %% Cody: Basic Operations 002
% 
% A = [-6:2:6];
% A1 = abs(A);
% A2 = sqrt(A1);
% 
% B = [9:-3:-12];
% B1 = B / 3;
% B2 = rem(B, 4);
% 
% C1 = log10(A1);
% C2 = exp(B1);
% 
% %% Cody: Matrix Operations
% % matrices to manipulate, use numbers in this section
% a = [15,3,22;3,8,5;14,3,82];
% b = [1;5;6];
% c = [12,18,5,2];
% 
% % manipulations, use indexing in this section
% d = a(:,2);
% e = [b,d];
% f = [a(3,:),c];
% g = [a;c(:,1:3)];
% h = [a(1,3),c(1,2),b(2,1)];
% 
% %% Cody: Electrical
% % Use R1, R2 and R3 in your expression, assume that they are already defined.
% RT = 1 / ( (1/R1) + (1/R2) + (1/R3) );
% 
% %% Cody: Statics
% mag = sqrt(a^2 + b^2);
% pos = [a/mag, b/mag];
