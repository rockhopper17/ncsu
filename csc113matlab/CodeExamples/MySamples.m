
%% zybooks chp 9.9 challenge section

% Player 1 and player 2 take turns playing a game. Row array gameScores contains the scores of player 1, then player 2, then player 1, and so on
function playerOneScores = GetPlayerScores(gameScores)
% gameScores: Array contains both player1 and player2's scores. Array contains 8 elements

    % FIXME: Construct a logic array to indicate which elements belong to player 1
    playerOnesEntries = repmat([true, false], [1, size(gameScores,2) / 2]);
    
    % Do not modify the following statement
    playerOneScores = gameScores(playerOnesEntries);

end


