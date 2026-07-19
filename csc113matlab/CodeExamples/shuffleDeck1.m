function  D = shuffleDeck1(D)

n = length(D);
for i=1:n    
    %pick a random index in the deck
    randIndex = randi(n,1);
    %swap the cards;
    savedCard = D{i};
    D{i} = D{randIndex};
    D{randIndex} = savedCard;    
end
end

