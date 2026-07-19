%%
function cash = diceGame( varargin )
%DICEGAME simulates the rolling of a die.  If you roll a 5 or 6
%         seven or more times, you win $2
%         three or more times, you win $1
%         less than three times then you win no money
%Inputs: if argument passed in, it is the number of times to roll the dice
%        if no argument, then roll the dice 10 times.
%Returns: cash the money won

%is an argument passed in?
if nargin == 0
    numRolls = 10;
else
    numRolls = varargin{1};
end
% roll the dice
result = randi([1,6], 1, numRolls);
%determine number of 5s and 6s
num5 = sum ( result == 5   );
num6 = sum ( result == 6   );
%determine the cash won
if (num5 > 7 || num6 > 7 )
    cash = 2;
elseif (num5 > 3 || num6 > 3 )
    cash = 1;
else
    cash = 0;
end

end


