% Andrew Navratil, anavrat
% 2017-09-27
% Lab Section #205
% Project 2: Dice Game, Fall 2017
% Description: function calcPoints implementation

%% function implementation
function points = calcPoints( currentBet, win, exactly7 )
% Calculates the points either gained or lost during the current roll
% Input:
%	currentBet: is an integer of what the points the player has bet
%	win: is logical TRUE or FALSE if the player won the current roll
%	exactly7: is logical TRUE or FALSE if the user has picked EXACTLY 7
% Return:
%	points: is a positive or negative integer for the number of points
%			the player has gained or lost.
%			If the player has lost, they lose the amount of points in the bet
%			If the player has won, they gain 1:1 for UNDER 7 and for OVER 7
%			and they gain 4:1 for EXACTLY 7

% first see if they won
if (win)
	% next check if they picked exactly 7, if so multiply current bet by 4, else just return current bet
	if (exactly7)
		points = 4 * currentBet;
	else
		points = currentBet;
	end
else
	% they lost, so return negative amount of current bet
	points = -currentBet;
end
