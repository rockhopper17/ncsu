function dum = y(z)
% equation 5.38 from book
global r1 r2 A
dum = r1 + r2 + A*(z*S(z) - 1)/sqrt(C(z));

end

