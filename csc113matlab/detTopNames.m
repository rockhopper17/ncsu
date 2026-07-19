% Andrew Navratil
% anavrat@ncsu.edu
% 2017-11-13
% Section #205
% Project 3: Baby Names, Fall 2017

function topNames = detTopNames( yearOfB, top )
% Determines the top girl and boy names in a particular year
% by getting that info from the input data file for that year.
% Input:	yearOfB is an integer between [1880 and 2016]
%			top is an integer between [0 and 100]
% Return:	topNames is a Cell Array with top rows and two columns
%				the first column is the top girl names as char arrays
%				the second column is the top boy names as char arrays

% initialize topNames and count of male/female names found
topNames = cell(top,2);
numMale = 0;
numFemale = 0;

% open file for desired year
fname = sprintf('yob%s.txt',num2str(yearOfB));
fid = fopen(fname);

% read file to pull out the top names
while ~feof(fid)
	% use textscan and fgetl to read data line by line
	ndata = textscan(fgetl(fid),'%s %s %d','delimiter',',');

	% get top female and male names into the cell array as char arrays
	if strcmpi(ndata{2},'f') && numFemale < top
		numFemale = numFemale + 1;
		topNames{numFemale,1} = char(ndata{1});
	elseif strcmpi(ndata{2},'m') && numMale < top
		numMale = numMale + 1;
		topNames{numMale ,2} = char(ndata{1});
	end

	% stop searching when we find all the names we want
	if numFemale >= top && numMale >= top
		break;
	end
end

% close file
fclose(fid);

end
