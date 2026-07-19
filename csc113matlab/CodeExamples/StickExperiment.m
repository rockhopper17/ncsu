% A stick of unit length is randomly split in two pieces.  Estimate the
% average length of the short piece.

n= 10000000;  % number of trials
total= 0;  % accumulated length of short pieces so far

%simulate the experience and record the total length
%of all the short pieces
for k= 1:n
    breakPt = rand;
    shortPiece = min(breakPt, 1-breakPt);
    total = total + shortPiece;
end

%calculate average length
aveLength = total/n;
%print the result
fprintf('Estimated average length is %.4f (%d trials)\n', aveLength, n)
