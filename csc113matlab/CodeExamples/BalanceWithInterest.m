function finBalance = BalanceWithInterest( rate, initBalance )
% Calculates the final balance of an investment with compound interest
% Inputs: rate -- Interest rate  
%         initBalance -- Initial balance. 
% Output: finBalance -- Final balance 

interest   = rate * initBalance;     % Calculate the interest
finBalance = initBalance + interest; % Calculate the final balance

end
