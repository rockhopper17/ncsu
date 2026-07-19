% Andrew Navratil
% 2017-11-2
% Section #205
% Homework 7

clear;close all;clc;

%% 1. structure array with metals table including input for additional entries

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

% store the metals info in a structure array
for i = 1:length(symbols)
	elementS(i).name = names{i};
	elementS(i).symbol = symbols(i);
	elementS(i).atomNum = atomicnum(i);
	elementS(i).atomWgt = atomicwgt(i);
	elementS(i).density = density(i);
	elementS(i).crystal = crystal(i);
end

% prompt user to enter additional elements
while true
	enterAddl = input('Would you like to input an element? (Y or N) ','s');

	% increment index
	i = i + 1;

	% if yes, gather input for additional element
	if strcmp(enterAddl,'Y')
		name = input('What is the name? ','s');
		symbol = input('Symbol? ','s');
		an = input('Atomic number? ');
		aw = input('Atomic weight? ');
		d = input('Density? ');
		cs = input('Crystal Structure? (FCC, BCC, or HCP) ','s');
		fprintf('\n');

		% insert the additional element
		elementS(i).name = name;
		elementS(i).symbol = symbol;
		elementS(i).atomNum = an;
		elementS(i).atomWgt = aw;
		elementS(i).density = d;
		elementS(i).crystal = cs;
	else
		break;
	end
end

%% 2. milling.xlsx import and structure array creation

% import data using xlsread
[~,~,raw] = xlsread('milling.xlsx');

% get number of rows and columns
[numr,numc] = size(raw);

% loop rows and columns to create a structure array with headers as field names
for r = 2:numr
	for c = 1:numc
		% get header for fieldname, removing spaces
		fieldname = strrep(raw{1,c},' ','');

		millingDat(r-1).(fieldname) = raw{r,c};
	end
end

% print output to a text file MillingResults.txt
fid = fopen('MillingResults.txt','w');

for r = 1:numr-1
	fprintf(fid,'For part number %d, the ideal weight is %.2f kg.\n',...
		millingDat(r).PartNumber, millingDat(r).IdealWeight);
	fprintf(fid,'Trial\t\t1\t2\t3\t4\t5\t\n');
	fprintf(fid,'Weight (kg)\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t\n\n',...
		millingDat(r).Trial1,millingDat(r).Trial2,millingDat(r).Trial3,millingDat(r).Trial4,millingDat(r).Trial5);
end

% close file
fclose(fid);

%% 3. books.json import into structure array

% open the file books.json for reading
fid = fopen('books.json');

% get data into a cell array using textscan
json = textscan(fid,'%s','Delimiter','\n');

% now close file
fclose(fid);

% set json to a single cell array instead of the initial cell array of cells
% for ease of indexing
json = json{1};

% get num rows for looping
[numr,numc] = size(json);

% structure array to hold data
books = [];

% current index for books structure array
curidx = 1;

% parse json cell array in a loop
for i = 1:numr
	% if string value is open or close bracket, comma, or open curly brace then continue
	if sum(strcmp(json{i},{'[';']';',';'{'})) > 0
		continue;
	% increment to next index if we see a closing curly brace
	elseif strcmp(json{i},'}')
		curidx = curidx + 1;
	% now we are on a line of data
	else
		% use textscan to split the line on the colon
		val = textscan(json{i},'%s %s','Delimiter',':');

		% get fieldname from val{1}, replacing quotes and spaces
		fieldname = strrep(char(val{1}),'"','');
		fieldname = strrep(fieldname,' ','');

		% enter data into structure array
		% no instructions in homework on need to massage this data so just entering it raw
		books(curidx).(fieldname) = val{2};
	end
end

%% 4. colors.txt import into structure array

% open file colors.txt for reading
fid = fopen('colors.txt');

% get data into a cell array using textscan
data = textscan(fid,'%s %s','HeaderLines',1,'Delimiter',':');

% close file
fclose(fid);

% store data into a structure array
for i = 1:length(data{1})
	colors(i).name = strrep(data{1}{i},'"','');
	colors(i).hex = strrep(data{2}{i},'"','');
end

%% 5. integer to binary conversion

% prompt user for integer, with validation
while true
	n = input('Enter an integer: ');

	if (n >= 0 && rem(n,1) == 0)
		break;
	else
		fprintf('Invalid input.\n');
	end
end

% initialize a binary value, to be stored as a string of 0's and 1's
binstr = '';

% follow the decimal to binary conversion algorithm
while n > 0
	% first get the remainder after division by 2 and enter as leftmost value in string
	binstr = [num2str(rem(n,2)) binstr];

	% then set the value to the quotient of the division by 2
	n = floor(n / 2);
end

% output the binary value
fprintf('Binary: %s\n',binstr);


