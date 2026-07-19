% Andrew Navratil
% 2017-09-13
% Section #205
% Homework 3


%% Problem 1: Script 1
% each script will be used to determine which quadrant a user-inputted angle value belongs
% use four separate if statements

% get an angle from the user
A = input('Enter an angle value, in degrees, to see which quadrant it belongs: ');

% get the corresponding angle value between 0 and 360 degrees
a360 = rem(A,360);
aquad = 0;

if (a360 >= 0) && (a360 < 90)
	aquad = 1;
end

if (a360 >= 90) && (a360 < 180)
	aquad = 2;
end

if (a360 >= 180) && (a360 < 270)
	aquad = 3;
end

if (a360 >= 270) && (a360 < 360)
	aquad = 4;
end

fprintf('Your angle of %d degrees lies in qudrant %d\n', A, aquad);


%% Problem 1: Script 2
% use a single if-elseif-...-else-end construct

% get an angle from the user
A = input('Enter an angle value, in degrees, to see which quadrant it belongs: ');

% get the corresponding angle value between 0 and 360 degrees
a360 = rem(A,360);
aquad = 0;

if (a360 >= 0) && (a360 < 90)
	aquad = 1;
elseif (a360 >= 90) && (a360 < 180)
	aquad = 2;
elseif (a360 >= 180) && (a360 < 270)
	aquad = 3;
elseif (a360 >= 270) && (a360 < 360)
	aquad = 4;
end

fprintf('Your angle of %d degrees lies in qudrant %d\n', A, aquad);

%% Problem 1: Script 3
% use nested conditional statements, without elseif (staggered if statements)

% get an angle from the user
A = input('Enter an angle value, in degrees, to see which quadrant it belongs: ');

% get the corresponding angle value between 0 and 360 degrees
a360 = rem(A,360);
aquad = 0;

if (a360 < 90)
    aquad = 1;
else
    if (a360 < 180)
        aquad = 2;
    else
        if (a360 < 270)
            aquad = 3;
        else
            aquad = 4;
        end
    end
end

% or can do it this way nested, not sure what is wanted here exactly:
% if (a360 >= 0)
% 	aquad = 1;
% 	if (a360 >= 90)
% 		aquad = 2;
% 		if (a360 >= 180)
% 			aquad = 3;
% 			if (a360 >= 270) 
% 				aquad = 4;
% 			end
% 		end
% 	end
% end

fprintf('Your angle of %d degrees lies in qudrant %d\n', A, aquad);


%% Problem 2: determine triangle type

% test angle values (assignment doesn't ask for user input)
a = 20;
b = 80;
c = (180 - (a+b));

% use if statements to find type of triangle
if (a == b && a == c)
	disp('Equilateral triangle');
elseif (a == b || a == c || b == c)
	disp('Isosceles triangle');
else
	disp('Scalene triange');
end

%% Problem 3: calculate cost of mailing a package

% package weight, in lb
pkgweight = 17.25;

% initialize cost
cost = 0;

% present menu to user for selecting shipping method
shippingMethod = menu('Shipping Method','Ground','Air','Overnight');

% format output for dollars and cents
format bank;

% switch on shipping method, calculate cost based on weight for each
switch shippingMethod
	case 1
		% case for ground shipping
		if (pkgweight <= 2)
				cost = 1.5;
		elseif (pkgweight <= 10)
				% add $0.50 for each pound or fraction of a pound over 2 lbs to base of $1.50
				cost = 1.5 + (ceil(pkgweight - 2) * 0.5);
		elseif (pkgweight <= 50)
				% add $0.30 for each pound or fraction of a pound above 10 lbs to base of $5.50
				cost = 5.5 + (ceil(pkgweight - 10) * 0.3);
		end
	case 2
		% case for air shipping
		if (pkgweight <= 2)
				cost = 3;
		elseif (pkgweight <= 10)
				% add $0.90 for each pound or fraction of a pound over 2 lbs to base of $3.00
				cost = 3 + (ceil(pkgweight - 2) * 0.9);
		elseif (pkgweight <= 50)
				% add $0.60 for each pound or fraction of a pound above 10 lbs to base of $10.20
				cost = 10.2 + (ceil(pkgweight - 10) * 0.6);
		end
	case 3
		% case for overnight shipping
		if (pkgweight <= 2)
				cost = 18;
		elseif (pkgweight <= 10)
				% add $6.00 for each pound or fraction of a pound over 2 lbs to base of $18.00
				cost = 18 + (ceil(pkgweight - 2) * 6);
		elseif (pkgweight <= 50)
				% add $4.00 for each pound or fraction of a pound above 10 lbs to base of $66.00
				cost = 66 + (ceil(pkgweight - 10) * 4);
		end
	otherwise
		% no shipping method chosen
		cost = 0;
end

fprintf('The cost for shipping is $%.2f.\n', cost);

%% Problem 4: machine tolerance
% find out how many of the parts produced by a machine are within allowable tolerance
% can't use an if statement!

% part measurements
parts = [13.23, 15.01, 12.36, 16.11, 17.22, 11.69, 14.76, 15.55, 17.54, 16.77, 11.99];

% ideal length of part produced
idealLen = 15;

% allowable tolerance = 0.1 in
% change this to mm using 25.4 mm / 1 in
tol = (0.1 * 25.4 / 1);

% count num parts within tolerance
numInTol = sum(abs(parts - idealLen) <= tol);

fprintf('There are %d part measurements that fall within tolerance.\n', numInTol);

%% Problem 5: switch statement for displaying season for a chosen month

% prompt user to select a month
m = menu('Select a month','January','February','March','April','May','June',...
	'July','August','September','October','November','December');

switch m
	case {3, 4, 5}
		disp('Season is Spring');
	case {6, 7, 8}
		disp('Season is Summer');
	case {9, 10, 11}
		disp('Season is Fall!!!');
	case {12, 1, 2}
		disp('Season is Winter');
	otherwise
		disp('No month selected');
end
