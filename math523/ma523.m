close all; clear all; clc;

% complex line integral
g=@(theta) cos(theta) + i*sin(theta);
gprime = @(theta) -sin(theta) + i*cos(theta);

g2=@(t) t*(1+i);
gprime2 = @(t) 1+i;

g3=@(t) t;
gprime3 = @(t) 1;

%fun = @(z) z;
%fun = @(z) real(z);
fun = @(z) (conj(z)).^2;

%q1 = integral(@(t) fun(g(t)).*gprime(t),0,2*pi)
q1 = integral(@(t) fun(g(t)).*gprime(t),0,pi/4)
q2 = integral(@(t) fun(g2(t)).*gprime2(t),sqrt(2)/2,0)
q3 = integral(@(t) fun(g3(t)).*gprime3(t),0,1)

q1+q2+q3
