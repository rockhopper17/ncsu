%% NCSU, CSC 113, While Loop Example
%
% Simmulates the rolling of two dice until a sum of 7 is reached
% Also, prints the number of tries it took 

tries = 0;
sum = 0;
while (sum ~=7 )
    %roll first dice
    dice1 = ceil(6*rand); 
    %roll second dice
    dice2 = ceil(6*rand); 
    %get their sum
    sum = dice1 + dice2;
    %tell the user the values
    fprintf('%d + %d = %d\n', dice1, dice2, sum);
    tries=tries+1;
end
%tell the user how many tries it took
fprintf('You won after %d tries!\n', tries);
