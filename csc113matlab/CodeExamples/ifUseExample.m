%% NCSU CSC 113 Example on types of if-else
%  Given the function y=f(x), where
%       y = 1 if x < -1
%       y = x^2 if -1<= x <=2
%       y = 4 if x > 2


%% Write it with sequential if statements
x = -2; 
if x < -1
    y = 1;
end
if ( -1 <= x) && (x <= 2)
    y = x^2;
end
if x > 2
    y = 4; 
end
fprintf('x = %d, y = %d\n', x, y);
%% Write it with nested if-else 
x = 3;
if x < -1
    y = 1;
else
    if (x <= 2)
        y = x^2;
    else
        y = 4;
    end
end
fprintf('x = %d, y = %d\n', x, y);

%% Write it with nested if-elseif
x = 3;
if x < -1
    y = 1;
elseif x <= 2
    y = x^2;
else
    y = 4;h
end
fprintf('x = %d, y = %d\n', x, y);


