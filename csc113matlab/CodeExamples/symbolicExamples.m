%% symbolic variables, expressions
clear; clc;
syms x y;
eqn = (x+y)^5
expEqn = expand(eqn)
simplify(expEqn)

%%

t = 0:0.05:3 ;
position = (cos(6.*t) + sin(6.*t))./exp(2.*t);
velocity = diff(position)./diff(t);
plot(t,position, '*r', t(1:end-1), velocity, 'db');
legend('Position', 'Velocity');






