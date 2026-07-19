function dateNum2Str( numdate )
% convert a numeric date (1/2/2000) to its corresponding string value (January 2, 2000)
% displays the string in the command window, no output
%	Input: numdate - date in numeric vector form, i.e. [1,2,2000]

% store month names in a cell array
monthNames = {'January';'February';'March';'April';'May';'June';'July';'August'; ...
			'September';'October';'November';'December'};

% display the string version of the date in the command window
fprintf('%s %d, %d\n',monthNames{numdate(1)},numdate(2),numdate(3));

end
