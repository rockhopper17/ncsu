function xnew = step1(file, x, t, deltaT)
% function xnew = step1(file, x, t, deltaT)
% this m-file performs a 1st order numerical integration step (Euler)
% inputs
%	file	name of file that contains state equations
%	x		nx1 vector of state variables at time t
%	t		time
%	deltaT	time step
% outputs
%	xnew	nx1 vector of state variables at time t + deltaT
% calls
%	m-file

eval(['f = ',file,'(x,t);']);
deltax = deltaT*f;
xnew = x + deltax;

