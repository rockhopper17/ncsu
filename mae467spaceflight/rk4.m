% function xnew = rk4(x, t, deltaT, d)
% this m-file performs a 4th order numerical integration step (Runge-Kutta)
% inputs
%	x		nx1 vector of state variables at time t
%	t		time
%	deltaT	time step
%   d       struct with constants needed by orbits_state
% outputs
%	xnew	nx1 vector of state variables at time t + deltaT

function xnew = rk4(x, t, deltaT, d)
	f1 = orbits_state(x, t, d);
	f2 = orbits_state(x + (0.5 * deltaT * f1), t + (0.5 * deltaT), d);
	f3 = orbits_state(x + (0.5 * deltaT * f2), t + (0.5 * deltaT), d);
	f4 = orbits_state(x + (deltaT * f3), t + (deltaT), d);

	xnew = x + (deltaT/6) * (f1 + 2*f2 + 2*f3 + f4);
end

