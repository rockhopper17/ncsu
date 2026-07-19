function dum = F(z,t)
% equation 5.40 from book
global mu A
dum = (y(z)/C(z))^1.5*S(z) + A*sqrt(y(z)) - sqrt(mu)*t;
end