%% numerical techniques
clear; clc; 

recorded_t = [1 2 3 5 6 7]; %months since Oct, 2010
recorded_price = [3.14, 3.21, 3.31, 3.87, 4.06, 4.26] ;
%fit this recorded data to a 3rd degree polynomial
coeff_3 = polyfit(recorded_t, recorded_price, 3); 

%get the fitted prices based on that polynomial
t=1:7; %for all months
fitted_price = polyval(coeff_3,t); %what was the fitted price
fprintf('Estimated price for February, 2011 is %.2f\n', fitted_price(4));

%plot of the recorded AND the fitted data 
plot(t,fitted_price, 'b*-', recorded_t, recorded_price, 'rd')
text(3.5,fitted_price(4),'Feb')
grid on


