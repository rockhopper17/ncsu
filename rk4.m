function xnew = rk4(file, x, t, deltaT)
% function xnew = rk4(file, x, t, deltaT)
% this m-file performs a 4th order numerical integration step (Runge-Kutta)
% inputs
%	file	name of file that contains state equations
%	x		nx1 vector of state variables at time t
%	t		time
%	deltaT	time step
% outputs
%	xnew	nx1 vector of state variables at time t + deltaT
% calls
%	m-file

eval(['f1 = ',file,'(x,t);']);
eval(['f2 = ',file,'(x + 0.5*deltaT*f1,t + 0.5*deltaT);']);
eval(['f3 = ',file,'(x + 0.5*deltaT*f2,t + 0.5*deltaT);']);
eval(['f4 = ',file,'(x + deltaT*f3,t + deltaT);']);
xnew = x + (deltaT/6)*(f1 + 2*f2 + 2*f3 + f4);
