function cryptogram( str )
% creates a cryptogram puzzle from an input string
%	Input: str - string to be encrypted

% capitalize input string and convert to ascii, initializing encPhrase
encPhrase = double(upper(str));

% create encryption key where first row is all ascii values for the alphabet (upper case)
% second row is the ascii values scrambled using randperm
alphaAscii = [double('A'):double('Z')];
alphaScrambled = randperm(26) + (double('A') - 1);
encKey = [alphaAscii;alphaScrambled];

% create puzzle by replacing letters in input string with corresponding letters in the scrambled
% part of the key
for i = 1:length(encPhrase)
	% first locate the character in the unscrambled part of the key
	idx = find(encKey(1,:) == encPhrase(i));

	% if located (not a punctuation) then scramble it using the scrambled part of the key
	if ~isempty(idx)
		encPhrase(i) = encKey(2,idx);
	end
end

% convert key and puzzle back to characters
encKey = char(encKey);
encPhrase = char(encPhrase);

% output to command window
fprintf('Encryption Key:\n%s\n%s\n\n',encKey(1,:),encKey(2,:));
fprintf('Encrypted Phrase:\n%s\n',encPhrase);

end
