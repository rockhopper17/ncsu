% Andrew Navratil
% anavrat@ncsu.edu
% 2017-11-13
% Section #205
% Project 3: Baby Names, Fall 2017

%% welcome message and initial menu selection

% set const values for year range and top number of names range
MINYEAR = 1880;
MAXYEAR = 2016;
MINTOP = 0;
MAXTOP = 100;

% print welcome message
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('Welcome to the Baby Names Trends Program!');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

% menu selection
opt = menu('Select one:','Popular Names by Birth Year','Popularity of Names over Time');

%% Popularity of Names by Birth Year
if opt == 1
	% prompt for year of birth with validation
	while true
		yearOfB = input('Enter the Year [1880 to 2016]: ');

		% check to ensure the year entered is an integer in the valid range
		if rem(yearOfB,1) == 0 && yearOfB >= MINYEAR && yearOfB <= MAXYEAR 
			break;
		else
			disp('Incorrect year. Try again.');
		end
	end

	% prompt for top number of names to get
	while true
		top = input('Top Number: ');

		% check to ensure the top value entered is an integer in the valid range
		if rem(top,1) == 0 && top >= MINTOP && top <= MAXTOP 
			break;
		else
			disp('Incorrect number. Try again.');
		end
	end

	% call detTopNames and display output
	topNames = detTopNames( yearOfB, top);

	% get size of topNames (rows should equal top, but maybe not if not enough)
	[numr, numc] = size(topNames);

	% add a rank column for display
	dispTopNames = [num2cell(1:numr);topNames'];

	% print the output
	fprintf('Rank%18s%18s\n','Girls','Boys');
	fprintf('--------------------------------------------\n');
	fprintf('%4d%18s%18s\n', dispTopNames{:});

%% Popularity of Names over Time
elseif opt == 2
	% set a flag for plot initialization 
	initplot = true;
	
	%% main loop prompting for name or quit
	while true
        fprintf('\n');
        
		% get name to plot with validation
		while true
			% prompt for name or quit
			name = input('Enter name to plot (or ''q'' to quit): ','s');

			% validate name is not blank
			% no requirement listed to validate for letters, maybe names can contain spaces and numbers
			if isempty(name)
				disp('Incorrect input. Try again.');
			else
				break;
			end
		end

		% if name is q then quit, otherwise proceed
		if strcmpi(name,'q')
			% not sure if we should close the plot or not
			% close('all');
			break;
		end

		% we have a valid name, now prompt for gender with validation
		while true
			% prompt for gender
			gender = input('Gender [F or M] : ','s');

			% validate input is F f M m
			if sum(strcmpi(gender,{'f','m'})) < 1
				disp('Incorrect input. Try again.');
			else
				break;
			end
		end

		% get range of years
		while true
			% prompt for years to search
			yearRangeStr = input('Range of Years : ','s');

			% remove the brackets
			yearRangeStr = regexprep(yearRangeStr,'[\[\]]','');

			% pull out year values 
			yearRange = strsplit(yearRangeStr,' ');

			% check to ensure we have two numbers, otherwise just start over
			if length(yearRange) < 2
				disp('Incorrect range of years. Try again.');
				continue;
			else
				% now convert years to double and check
				yearOfBMin = str2double(yearRange{1});
				yearOfBMax = str2double(yearRange{2});

				% check to ensure we have a number and it is an integer in the valid range
				if isnan(yearOfBMin) || isnan(yearOfBMax)
					disp('Incorrect range of years. Try again.');
					continue;
				elseif yearOfBMin > yearOfBMax || rem(yearOfBMin,1) ~= 0 || rem(yearOfBMax,1) ~= 0
					disp('Incorrect range of years. Try again.');
					continue;
				elseif yearOfBMin < MINYEAR || yearOfBMax > MAXYEAR
					disp('Incorrect range of years. Try again.');
					continue;
				else
					break;
				end
			end
		end

		% initialize year range / x values for plot
		years = yearOfBMin:yearOfBMax;
		numYears = length(years);

		% variables for max popularity and corresponding year 
		maxval = 0;
		maxyear = 0;

		% initiliaze number of occurrences / y values for plot
		numOccur = zeros(numYears,1);

		% loop year range, call detNamePopularityInYear and enter into numOccur if not empty
		for i = 1:numYears
			curyear = years(i);	
			popularity = detNamePopularityInYear(curyear,name,gender);
			if ~isempty(popularity)
				numOccur(i) = popularity;

				% check to see if we have a new max
				if popularity > maxval
					maxval = popularity;
					maxyear = curyear;
				end
			end
		end	

		% display info and plot if name was found
		if maxval > 0
			% display year most popular
			fprintf('%s was most popular in %d with %d occurrences.\n\n',name,maxyear,maxval);
			
			% plot initialization if not already done
			% setup figure to hold multiple plots
			if initplot
				% create figure and hold on
				figure(1);
				hold on;

				% add annotations
				title('Names Popularity','FontSize',14);
				xlabel('Year');
				ylabel('Number of Occurrences');

				% reset initplot so we only initialize one time
				initplot = false;
			end

			% plot num occurrences vs year
			plot(years,numOccur,'LineWidth',2);

			% add text for name close to end of line graph
			dispname = sprintf('%s(%s)',name,gender);
			text(years(end),numOccur(end),dispname);
		else
			% name wasn't found, display message stating this
			fprintf('Name was NOT found!\n');
		end

	% end of main loop
	end

%% no choice made
else
	disp('no choice made');
end
