%% User Input: get a valid month & date
[month, monthNumber, monthNumDays] = getMonthFromUser( ); 
day = getDayFromUser( monthNumDays) ;

%% Determine the season and print the results
season = determineSeason( monthNumber, day );
fprintf('Entered Date: %s %d\n', month, day);
fprintf('The season is : %s\n', season);


