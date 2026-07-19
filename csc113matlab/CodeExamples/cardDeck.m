function D = cardDeck()
%CardDeck "creates" a deck of cards
% Inputs: none
% Returns: D - 1 by 52 cell array of strings that define a card deck

suit = {'Hearts  ', 'Clubs   ', 'Spades  ', 'Diamonds'};
rank = {' A', ' 2', ' 3', ' 4', ' 5', ' 6', ' 7', ' 8', ' 9', '10',' J',' Q',' K'};

D = cell(1,52); %empty deck

i = 1;  % index of the next card to be set up
for s= 1:length(suit)
    % Set up the cards in suit s
    for r= 1:length(rank)
        %set up all the ranks
        D{i} = [ rank{r} ' ' suit{s} ];
        i = i+1;
    end
end

