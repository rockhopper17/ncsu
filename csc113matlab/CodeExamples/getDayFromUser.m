%%
function day = getDayFromUser(numMonthDays)
% Interacts with the user, if the entered day is not valid for the 
% given month (e.g., 30 in February), the error message “Invalid day.” is
% printed the user is reprompted for the day until they enter a correct day. 
% Assume not in a leap year, so February 29th would be considered invalid
%
% Input: numMonthDays is an integer for the the number of days of the 
%                     selected month, e.g. for June 30, for February 28
% Returns: day is integer in the range [1 to numMonthDays]
while true
    %get input from user
    enteredInfo = input('Enter a day: ', 's');
    %convert to a number if possible
    [enteredDay] = str2double(enteredInfo);
    
    if ~isnan(enteredDay) %it was a number
        %check if integer
        if (enteredDay == floor(enteredDay))
            totNumDaysThatMonth = numMonthDays;            
            if enteredDay >= 1 && enteredDay <= totNumDaysThatMonth
                day = enteredDay;
                break
            else
                fprintf('Not a valid day.');
            end
        else
            fprintf('Not an integer.');
        end
    else
        fprintf('Not a number. ');
    end
end
end

