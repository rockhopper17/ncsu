function [ fmat ] = myFlip( mat )
% Flips a matrix along the horizontal dimension using programming methods
%	Input: mat - a m x n 2D array
%	Output:	fmat - input array mat flipped horizontally

% get the number of rows and cols of matrix
[numrows,numcols] = size(mat);

% initialize fmat
fmat = zeros(numrows,numcols);

% loop through the rows accordingly
for m = 1:numrows
	fmat(m,:) = mat(numrows - m + 1,:);
end

end
