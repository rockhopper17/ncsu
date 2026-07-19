%%

function output = calcStuff_nested(x1, x2)
%main function does some calculation
m = multiply();
d = divide();
output = m + d;
    function m_result = multiply()
        %nested function that multiplies x1 by x2
        m_result = x1.*x2;
    end

    function d_result = divide()
        %nested function that divides x1 by x2
        d_result = x1./x2;
    end

end