% Andrew Navratil
% 2017-08-28
% Section #205
% Homework 1

%% Problem 1
%clear all; close all; clc;

% create matrix mat to contain [-2/3, -1/3, 0, 1/3, 2/3]
mat = -2/3:1/3:2/3

% a: i - vii: various format options for displaying the values in the matrix mat 
format long; % scale fixed point to 15 digits for double, 7 for single
mat

format bank; % format for dollars and cents
mat

format longe; % scale float to 15 digits for double, 7 for single
mat

format shorte; % float with 5 digits
mat

format compact; % suppress extra line feeds
mat

format loose; % put in default extra line feeds
mat

format rat; % approximation by ratio of small integers
mat

format short; % fixed with 5 digits
mat

% b: copy mat into each row of 2x5 mat2
mat2 = [mat;mat]

% c: transpose mat2 save as mat3
mat3 = mat2'

% d: create matrix with 5 linearly spaced values between -1 and 1, save as mat4
%    dot multiply mat4 with mat, save as mat5
mat4 = linspace(-1,1,5)
mat5 = mat.*mat4

% e: round each element of mat4 to the nearest integer
mat4 = round(mat4)

% f: select 3rd element in mat4 an dname ele3
ele3 = mat4(3)

%% Problem 2
%clear all; close all; clc;

x = 3;
y = 15;

z = ( ( (x * y) + (y / x) - sin(y^2) ) / ( (x + y)^(y-x) ) ) + log(12^(x/y))

%% Problem 3
%clear all; close all; clc;

A = [5,2,4,9; 1,7,-3,4; 6,-10,0,7; 8,5,1,-9]
B = [2,-5,8,9; 5,8,3,-7; 8,7,-9,2; 3,-4,1,6]

% evaluate A*B: performs a matrix multiplication; num cols A must equal num rows B
matMultAB = A*B

% evaluate A.*B: performs an element-by-element multiplication; A and B must be same size
elemMultAB = A.*B

%% Problem 4
%clear all; close all; clc;

x = magic(3)

% a: move each row of x up by one, first is now last
x1 = [x(2:end,:); x(1,:)]

% b: move each column of x right by one, last is now first
x2 = [x(:,end), x(:,1:end-1)]

% c: copy elements of 2nd row to create new 4th row
x3 = [x; x(2,:)]

% d: create new magic 4x4 and add to right of x3 for a new 4x7
x4 = [x3, magic(4)]

% e: find max in each column and row of x4
maxInCol = max(x4,[],1)
maxInRow = max(x4,[],2)

% f: find mean of all elements in x4 (use nested mean)
%    or can flatten first: mean(x4(:))
meanX4 = mean(mean(x4))
%mean(x4(:))

% g: use fliplr to flip columns of x4 about vertical axis
x5 = fliplr(x4)

% h: use flipud to flip rows of x4 about horizontal axis
x6 = flipud(x4)

%% Problem 5
%clear all; close all; clc;

tenThousand = 100:50:10000;

% a: find num elements using length command
lenTenThousand = length(tenThousand)

% b: take sine (in radians) of tenThousand
sinVals = sin(tenThousand)

% c: take absolute value of answer from part b
absSinVals = abs(sinVals)

% d: select 10th num from part c and call: ceil, floor, round
ceilVal = ceil(absSinVals(10))
floorVal = floor(absSinVals(10))
roundVal = round(absSinVals(10))

%% Problem 6
%clear all; close all; clc;

% verify sin^2 + cos^2 = 1 in a single line using five values for angle: 0, pi/2, pi, 3pi/2, 2pi
sinCosSq = sin([0:pi/2:2*pi]).^2 + cos([0:pi/2:2*pi]).^2

%% Problem 7
%clear all; close all; clc;

% use factorial to compute: 4!, 8!, 15!, 16!, 23!, 42!
fact4 = factorial(4)
fact8 = factorial(8)
fact15 = factorial(15)
fact16 = factorial(16)
fact23 = factorial(23)
fact42 = factorial(42)