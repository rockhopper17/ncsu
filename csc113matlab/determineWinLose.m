% Andrew Navratil, anavrat
% 2017-09-27
% Lab Section #205
% Project 2: Dice Game, Fall 2017
% Description: function determineWinLose implementation

%% function implementation
function win = determineWinLose( playerGuess, sumRoll )
% Determines if the player has won based on their guess and their
% current roll of the dice
% Input:
%	playerGuess: integer either 1 (UNDER 7), 2 (EXACTLY 7), or 3 (OVER 7)
%	sumRoll: integer sum of the two dice
% Return:
%	win: logical TRUE or FALSE

% player wins
if ((playerGuess == 1 && sumRoll < 7) || (playerGuess == 2 && sumRoll == 7)...
	|| (playerGuess == 3 && sumRoll > 7) )
	win = true;
else
	win = false;
end
