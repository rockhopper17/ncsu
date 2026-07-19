function output = calcStuff(x1, x2)
%main function does some calculation
m = multiply(x1,x2);
d = divide(x1,x2);
output = m + d;
end

function m_result = multiply(a,b)
%subfunction that multiplies x1 by x2
m_result = a.*b;
end

function d_result = divide(c,d)
%subfunction that divides x1 by x2
d_result = c./d;
end


