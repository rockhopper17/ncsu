% Andrew Navratil, anavrat
% 2017-09-27
% Lab Section #205
% Project 2: Dice Game, Fall 2017
% Description: main game implementation

%% introduction

% print the welcome message
fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
fprintf('WELCOME TO THE OVER 7 UNDER 7 DICE GAME!\n');
fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

% get the player's name
pname = input('Enter your name: ','s');

% variable to start a new game
newGame = true;

% variable to see if we keep rolling or not
keepRolling = true;

%% game loop
while (keepRolling)
	% reset current points won/lost to 0, bad bet to false
	points = 0;

	% if starting a new game, initialize points, bet and show welcome messages
	if (newGame)
		% reset newGame to false so we don't keep starting over
		newGame = false;
		
		% initialize bank points, current bet
		bankPoints = 10;
		currentBet = 0;

		% display good luck message and initial bank points
		fprintf('\nGood luck %s!\n',pname);
		fprintf('Bank points: %d\n',bankPoints);
		fprintf('Begin playing...\n');
		fprintf('--------------------------------------------------------\n\n');
	end

	% prompt user for their bet
	currentBet = input('How much points are you betting on the next roll: ');

	% validate currentBet then begin playing if good to go
	if (currentBet > 0 && currentBet <= bankPoints)
		% prompt user for their guess with a menu
		playerGuess = menu('What is your guess?', 'Under 7', 'Exactly 7', 'Over 7');
		
		% display message with their pick
		switch playerGuess
			case 1
				fprintf('->You picked UNDER 7.\n');
			case 2
				fprintf('->You picked EXACTLY 7.\n');
			case 3
				fprintf('->You picked OVER 7.\n');
			otherwise
				fprintf('->You didn''t make a choice.\n');
				continue;
		end

		% roll the two six sided dice for the player
		roll1 = randi(6);
		roll2 = randi(6);
		sumRoll = roll1 + roll2;

		% display message with roll
		fprintf('->You rolled %d and %d, which totals to %d.\n', roll1, roll2, sumRoll);

		% find out if player won
		win = determineWinLose(playerGuess, sumRoll);

		% find out how many points they won or lost
		points = calcPoints(currentBet, win, playerGuess == 2);

		% display message with win / lose with amount
		if (win)
			fprintf('->Good bet! You won %d points.\n', points);
		else
			fprintf('->Sorry! You lost %d points.\n', points);
		end
	else
		% print error message for type of bad bet
		if (currentBet > bankPoints) 
			fprintf('->You can''t bet this amount of points!\n');
			fprintf('->It is more than what you have in the bank!\n');
		elseif (currentBet < 0) 
			fprintf('->Can''t bet negative points!\n');
		elseif (currentBet == 0) 
			fprintf('->Can''t bet 0! You must bet some points!\n');
		end
		
		% display current bank points and start game loop again
		fprintf('->Bank Points: %d\n', bankPoints);
		continue;
	end

	% add points to bank
	bankPoints = bankPoints + points;

	% display message with new bank amount
	fprintf('->Bank Points: %d\n', bankPoints);

	% check the total to see if they won or have no nore points, or want to roll again
	if (bankPoints >= 30)
		fprintf('\nCongratulations you completed a great game!\n');
		keepRolling = false;
	elseif (bankPoints <= 0)
		fprintf('\nGame over! You have no more bank points!\n');
		keepRolling = false;
	else
		while(true)
            % this will set keepRolling to true (1) for continue, or false (0) for quit
			keepRolling = input('To keep rolling enter 1, to quit enter 0: ');
			
			% validate they entered a 1 or 0
			if (keepRolling == 1)
				break;
			elseif (keepRolling == 0) 
				fprintf('\nGood game %s! You still had some bank points.\n', pname);
				break;
			else
				fprintf('Wrong Input. Try again.\n');
			end
		end	
	end

	% if keepRolling is false, see if they want to play again
	if (keepRolling == false)
		fprintf('--------------------------------------------------------\n\n');
		while(true)
			playAgain = input('Do you want to play again? (y/n): ','s');
			
			% validate they entered a y or n
			if (playAgain == 'y')
				keepRolling = true;
				newGame = true;
				break;
			elseif (playAgain == 'n')
				fprintf('\nGood bye %s!\n',pname);
				break;
			else
				fprintf('Wrong Input. Try again.\n');
			end
		end
	end
end
