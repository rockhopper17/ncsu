% function f = orbits_state(x, t, d)
% this m-file lists the state equations
% inputs
%	x(t)	nx1 vector of state variables at time t
%	t		time
%   d       struct with data: G, m, n, ndim (see ic.m for more info)
% outputs
%	f(x,t)	nx1 vector of time derivatives of state variables

function f = orbits_state(x, d)
    % get constants from d and set to locals
    G = d.G;
    m = d.m;
    n = d.n;
    ndim = d.ndim;

    % f holds the state equations, which are dot and double dot values
    % velocity / first derivatives (x dot, y dot, z dot] go in the first half of f
    % acceleration / second derivatives are calculated below
	f = zeros(1,2*ndim*n);
	f(1:ndim*n) = x(ndim*n+1:end);

	% distance between bodies and corresponding unit vectors
	% r(i,j) = distance from ith body to jth body
	% e(i,j,[x/y/z]) = unit vector for x/y/z dir from ith body to jth body
	r = zeros(n,n);
	e = zeros(n,n,ndim);

	for i = 1:n
		for j = 1:n
			%r(i,j) = norm( x((i-1)*ndim+[1:ndim]) - x((j-1)*ndim+[1:ndim]) );
			%e(i,j,[1:ndim]) = (x((j-1)*ndim+[1:ndim]) - x((i-1)*ndim+[1:ndim])) / r(i,j);
			%if i == j we are on the same body, so just keep the 0 value alredy in there
			if i ~= j
				sumk = 0;
				for k = 1:ndim
					sumk = sumk + (x((i-1)*ndim+k) - x((j-1)*ndim+k))^2;
				end
				r(i,j) = sqrt(sumk);
				
				%could still have distance = 0, for example rocket following earth for awhile
				if r(i,j) ~= 0
					for k = 1:ndim
						e(i,j,k) = (x((j-1)*ndim+k) - x((i-1)*ndim+k)) / r(i,j);
					end
				end
			end
		end
	end

    % acceleration / second derivatives [x double dot, y double dot]
    % derived from Newton: F = m1 a1 = G m1 m2 / r^2 => a1 = G m2 / r^2
	for i = 1:n
		%f(ndim*n+((i-1)*ndim+[1:ndim])) = sum(G*m.*e(i,:,1:ndim)./r(i,:).^2,'omitnan');
		for k = 1:ndim
			sumj = 0;
			for j = 1:n
				if i ~= j && r(i,j) ~= 0
					sumj = sumj + ((G * m(j) * e(i,j,k)) / r(i,j)^2);
				end
			end
			f(ndim*n+((i-1)*ndim+k)) = sumj;
		end
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
end

