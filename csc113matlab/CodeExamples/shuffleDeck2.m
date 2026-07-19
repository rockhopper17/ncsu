function  D = shuffleDeck2(D)

n = length(D);
%shuffle the index using built-in command randperm
shuffleIndex = randperm(n);
%shuffle the deck with logical indexing
D = D(shuffleIndex);

end

