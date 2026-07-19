%%
function [month, monthNumber, monthNumDays] = getMonthFromUser( )
%Interacts with user, if the month isn’t a match to full name 
% of one of the calendar months, then the error message “Invalid month.” 
% is printed and the user will  be reprompted for the month until they 
% enter a correct month.  
% Input: MONTHS is a Cell Array with the 12 months
% Returns: month is a char Array/string that is a valid month, e.g. 'March'
%          monthNumber is the corresponding number to month, e.g. 3

% Defines the months and their number of days
MONTHS = {'January', 'February', 'March', 'April', 'May', 'June', 'July', ...
          'August', 'September', 'October', 'November', 'December'};
%Max days in each month. */
DAYS_IN_MONTHS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

while true
    enteredMonth = input('Enter a month: ', 's');
    %check the validity of the entered month
    monthNumber = find(strcmpi(MONTHS, enteredMonth));
    if ~isempty(monthNumber) %it is one of the months
        month = enteredMonth;
        monthNumDays = DAYS_IN_MONTHS(monthNumber);
        break;
    else %it was not a valid month
        fprintf('Invalid month. Try again.\n');
    end
end
end

