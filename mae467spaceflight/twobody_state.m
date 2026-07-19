% function to calculate state space vector at next interval
% inputs
%	t		time
%	x(t)	nx1 vector of state variables at time t
% outputs
%	f(x,t)	nx1 vector of time derivatives of state variables

function f = twobody_state(t,x)
	% globals set in main script
	global G m

	% init return vector
	f = zeros(12,1);

	% pull out position and velocity vectors
	r1 = x(1:3);
	r2 = x(4:6);
	v1 = x(7:9);
	v2 = x(10:12);

	% calculate distance between objects
	r = norm(r2 - r1);

	% calculate acceleration values
	a1 = G * m(2) * (r2 - r1) / r^3;
	a2 = G * m(1) * (r1 - r2) / r^3;

	% combine vel and accel back into return vector
	f = [v1;v2;a1;a2];
end
