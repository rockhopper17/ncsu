%%
clear; clc;
a=3; b=11;
for n = a:b
    %GIVEN n, determine if prime
    divisor = 2;
    
    while ( rem(n,divisor) ~= 0 )
        divisor = divisor + 1;
    end
    
    if ( divisor == n )
        fprintf('%d is prime\n', n)
    else
        fprintf('%d is composite\n', n)
    end
end

