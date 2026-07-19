function promptNvec
% prompts user for an integer n and returns a vector from 1 to n

% prompt user for integer with validation
while(true)
	n = input('Enter a positive integer for n: ');

	if (n > 0 && rem(n,1) == 0)
		break;
	else
		fprintf('Invalid! ');
	end
end

% output the vector 1 to n
fprintf('Your vector is:\n');
fprintf('%5d',[1:n]);
fprintf('\n');

end
