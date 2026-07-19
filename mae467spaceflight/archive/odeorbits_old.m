% ode functions for orbits

% call ic.m script to set initial condition variables
ic

% Runge-Kutta 4th order integration
function xnew = rk4(x, t, deltaT)
    % perform the runge-kutta 4th order integration steps
    f1 = orbits_state(x, t);
    f2 = orbits_state(x + (0.5 * deltaT * f1), t + (0.5 * deltaT));
    f3 = orbits_state(x + (0.5 * deltaT * f2), t + (0.5 * deltaT));
    f4 = orbits_state(x + (deltaT * f3), t + (deltaT));

    xnew = x + (deltaT/6) * (f1 + 2*f2 + 2*f3 + f4);
end  % end rk4

% state equations
function f = orbits_state(x, t)
	% get x values and y values
	xvals = x(1:2:2*n-1);
	yvals = x(2:2:2*n);

	% velocity / first derivatives (x dot, y dot)
	f(1:2*n) = x(2*n+1:4*n);

	% distance between bodies and corresponding unit vectors
	% r(i,j) = distance from ith body to jth body
	% ex(i,j) or ey(i,j) = unit vector for x,y dir from ith body to jth body
	% todo: optimize this code to remove repeated calculations and unit vectors
	r = zeros(n,n);
	ex = zeros(n,n);
	ey = zeros(n,n);
	for i = 1:n
		r(i,1:end) = sqrt( (xvals(i) - xvals(1:end)).^2 + (yvals(i) - yvals(1:end)).^2 );
		ex(i,1:end) = (xvals(1:end) - xvals(i)) ./ r(i,:);
		ey(i,1:end) = (yvals(1:end) - yvals(i)) ./ r(i,:);
	end

	% set all NaN values to zero for calculations below
	ex(isnan(ex)) = 0;
	ey(isnan(ey)) = 0;

	% acceleration / second derivatives (x double dot, y double dot)
	% derived from Newton: F = G m1 m2 / r^2
	%   note: unit vector value of 0 for ith-ith (same body) will take care of
	%		the acceleration value of a body relative to itself
	%		but still must use omitnan for sum function
	for i = 1:n
		f(2*n+(2*i-1)) = sum(G.*m.*ex(i,1:end)./r(i,1:end).^2,'omitnan');
		f(2*n+(2*i)) = sum(G.*m.*ey(i,1:end)./r(i,1:end).^2,'omitnan');
	end

	% energy calculations
	% sum these
	% if you get delta E,
	% total E is constant, not for each object
	% do this before the integration
	%E = zeros(n,n);
	%for i = 1:n
		%E(i,1:end) = -G*m(i).*m./r(i,:);
	%end
end % end orbits_state

