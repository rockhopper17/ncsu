function collatzplot(m)
% Plot length of sequence for Collatz problem
% Prepare figure

% Determine and plot sequence and sequence length
for N = 1:m
	plot_seq = collatz(m;
	seq_length(N) = length(plot_seq)
end
plot(1:m,seq_length, 'r*','MarkerSize',20)
axis([-1 m+1 -1 max(seq_length)]);
title('Number of Integers in Collatz Series')
xlabel('m');


end