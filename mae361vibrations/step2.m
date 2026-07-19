function xnew = step2(file, x, t, deltaT)
% function xnew = step2(file, x, t, deltaT)
% this m-file performs a 2nd order numerical integration step (Runge-Kutta)
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
deltax1 = deltaT*f1;
eval(['f2 = ',file,'(x + deltax1,t + deltaT);']);
%xnew = x + 0.5*deltaT*(f1 + f2);

coder.cinclude('step2.h');
fcomb = coder.ceval('step2',coder.rref(f1), coder.rref(f2), coder.wref(out), int32(numel(f1)) );
xnew = x + 0.5*deltaT*(fcomb);
