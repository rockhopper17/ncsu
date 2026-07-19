function [V1,V2] = lambert_eq(R1,R2,t,string)
%
% This function solves Lambert’s problem.
%
% mu - gravitational parameter (kmˆ3/sˆ2)
% R1, R2 - initial and final position vectors (km)
% r1, r2 - magnitudes of R1 and R2
% t - the time of flight from R1 to R2
% (a constant) (s)
% V1, V2 - initial and final velocity vectors (km/s)
% c12 - cross product of R1 into R2
% theta - angle between R1 and R2
% string - 'pro' if the orbit is prograde
% 'retro' if the orbit is retrograde
% A - a constant given by Equation 5.35
% z - alpha*xˆ2, where alpha is the reciprocal of the
% semimajor axis and x is the universal anomaly
% y(z) - a function of z given by Equation 5.38
% F(z,t) - a function of the variable z and constant t,
% given by Equation 5.40
% dFdz(z) - the derivative of F(z,t), given by
% Equation 5.43
% ratio - F/dFdz
% tol - tolerance on precision of convergence
% nmax - maximum number of iterations of Newton’s
% procedure
% f, g - Lagrange coefficients
% gdot - time derivative of g
% C(z), S(z) - Stumpff functions
% dum - a dummy variable
%
% User M-functions required: stumpC and stumpS
% -----------------------------------------------------------
global mu
global r1 r2 A

%...Magnitudes of R1 and R2:
r1 = norm(R1);
r2 = norm(R2);
c12 = cross(R1, R2);
theta = acos(dot(R1,R2)/r1/r2);
%...Determine whether the orbit is prograde or retrograde:
if strcmp(string, 'pro')
if c12(3) <= 0
theta = 2*pi - theta;
end
elseif strcmp(string,'retro')
if c12(3) >= 0
theta = 2*pi - theta;
end
else
string = 'pro'
fprintf('\n ** Prograde trajectory assumed.\n')
end
%...Equation 5.35:
A = sin(theta)*sqrt(r1*r2/(1 - cos(theta)));
%...Determine approximately where F(z,t) changes sign, and
%...use that value of z as the starting value for Equation 5.45:
z = -100;
while F(z,t) < 0
z = z + 0.1;
end

%...Set an error tolerance and a limit on the number of iterations:
tol = 1.e-8;
nmax = 5000;
%...Iterate on Equation 5.45 until z is determined to within
%...the error tolerance:
ratio = 1;
n =0;
while (abs(ratio) > tol) & (n <= nmax)
n = n + 1;
ratio = F(z,t)/dFdz(z);
z = z - ratio;
end
%...Report if the maximum number of iterations is exceeded:
if n >= nmax
fprintf('\n\n **Number of iterations exceeds')
fprintf(' %g \n\n ', nmax)
end
%...Equation 5.46a:
f = 1 - y(z)/r1;
%...Equation 5.46b:
g = A*sqrt(y(z)/mu);
%...Equation 5.46d:
gdot = 1 - y(z)/r2;
%...Equation 5.28:
V1 = 1/g*(R2 - f*R1);
%...Equation 5.29:
V2 = 1/g*(gdot*R2 - R1);

end

