function season = determineSeason( monthNumber, day )
%% Determines season based on month number and day
% Input:
% monthNumber is the numeric representation of a month, e.g. 4 is April
% day is a valid day for that month
% Returns: season is a char array/string, Winter/Spring/Summer/Fall
if (monthNumber >=1 && monthNumber <= 3)
    season = 'Winter';
    if (monthNumber == 3 && day >=21 )
        season = 'Spring';
    end
elseif (monthNumber >=4 && monthNumber <= 6)
        season = 'Spring';
    if (monthNumber == 6 && day >=21 )
        season = 'Summer';
    end
elseif (monthNumber >=7 && monthNumber <= 9)
        season = 'Summer';
    if (monthNumber == 9 && day >=21 )
        season = 'Fall';
    end    
else
    season = 'Fall';
    if (monthNumber == 12 && day >=21 )
        season = 'Winter';
    end    
end
end

    