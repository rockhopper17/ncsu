% Andrew Navratil
% anavrat@ncsu.edu
% 2017-11-13
% Section #205
% Project 3: Baby Names, Fall 2017

function popularity = detNamePopularityInYear( yearOfB, name, gender )
% Determines the occurences(popularity) of a particular name given the
% gender and the year of birth by searching in the input data file.
% Input:	yearOfB is an integer between [1880 and 2016], year of birth
%			name	is a string for the name to search for
%			gender	is a string either 'f', 'F', 'm' or 'M'
% Return:
%		popularity if name found in year of birth input file then it is
%					an int32, if name is NOT found then empty vector

% initialize popularity
popularity = [];

% open file for desired year
fname = sprintf('yob%s.txt',num2str(yearOfB));
fid = fopen(fname);

% read file line by line searching for name
while ~feof(fid)
	% use textscan and fgetl to read data line by line
	ndata = textscan(fgetl(fid),'%s %s %d','delimiter',',');
	
	% seacrh for name and gender
	if strcmpi(ndata{1},name) && strcmpi(ndata{2},gender)
		% found, so return count as int32 in popularity and break
		% don't return immediately so we still close file handle but exit loop
		popularity = int32(ndata{3});
		break;
	end
end

% close file
fclose(fid);

end
