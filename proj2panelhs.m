% Andrew Navratil
% MAE 252 Spring 2018
% Project 2: Hess-Smith Panel Method
% Due 2018-05-07

% clear all vars and plots
close all; clear all; clc;

%pi = 4.0*atan(1.0)

%inputs:  uinf (free-stream velocity)
%	   alpha (angle of attack; degrees)
alphaRangeDeg = -5:5:15;
alphaRangeRad = alphaRangeDeg*pi/180.0;
colors = {'k','b','g',[.75 0 .75],'r'};
uinf = 50;
airfoilName = 'ME163 Komet';

%alpha = alpha*pi/180.0;

%c ----- import panel coordinates (x, y (1:npanel+1))
%c ----- Note:  ordering must be from bottom trailing edge to top trailing edge (clockwise)
data = load('data/me163-panel.txt');

% pull out x and y coords
x = data(:,1);
y = data(:,2);
npanel = numel(x)-1;

% calculate normal and tangent vectors for each panel
for j=1:npanel
	ds(j) = sqrt((x(j+1)-x(j))^2 + (y(j+1)-y(j))^2); % panel length
	tnx(j) = (x(j+1)-x(j))/ds(j);  % x component of panel tangent = cos(theta_j)
	tny(j) = (y(j+1)-y(j))/ds(j);  % y component of panel tangent = sin(theta_j)
	xnx(j) = -tny(j);              % x component of panel normal
	xny(j) =  tnx(j);              % y component of panel normal
end

%c ---- apply V dot n = 0.0 for every panel (boundary condition)
for i=1:npanel
	xi = 0.5*(x(i)+x(i+1));
	yi = 0.5*(y(i)+y(i+1));
	sumn = 0.0;
	sumt = 0.0;
	
	for j=1:npanel
		xj = x(j);
		yj = y(j);
		xip =  tnx(j)*(xi-xj) + tny(j)*(yi-yj);  %x* location in panel coord. system          
		yip = -tny(j)*(xi-xj) + tnx(j)*(yi-yj);  %y* location in panel coord. system
		upv = 0.5/pi*(atan2(yip,xip-ds(j))-atan2(yip,xip)); %x* velocity in panel coord. system.
		vpv = 0.25/pi*log(((xip-ds(j))^2 + yip^2)/(xip^2 + yip^2)); %y* velocity in panel coord. system
		if (i==j) 
			upv = 0.5;
			vpv = 0.0;
		end
		uv = tnx(j)*upv - tny(j)*vpv;  %x component of induced velocity in Cart. system
		vv = tny(j)*upv + tnx(j)*vpv;  %y component of induced velocity in Cart. system
		us = -vv; %x component of source velocity
		vs =  uv; %y component of source velocity
		a(i,j)  = us*xnx(i) + vs*xny(i); %matrix elements
		at(i,j) = us*tnx(i) + vs*tny(i); %matrix elements storing tangential components
		sumn = sumn + uv*xnx(i) + vv*xny(i);
		sumt = sumt + uv*tnx(i) + vv*tny(i);
	end
	
	a(i,npanel+1) = sumn;
	at(i,npanel+1) = sumt; 

	% calculate b for each alpha
	aidx = 1;
	for alpha = alphaRangeRad
		b(i,aidx) = -uinf*(cos(alpha)*xnx(i) + sin(alpha)*xny(i));
		aidx = aidx+1;   % this just tracks the column num in b for each alpha
	end

end

%c --- apply Kutta condition
for j=1:npanel+1;
	a(npanel+1,j) = at(1,j)+at(npanel,j);
end
% apply Kutta condition to b for each alpha
aidx = 1;
for alpha = alphaRangeRad
	b(npanel+1,aidx) = -uinf*(cos(alpha)*(tnx(1)+tnx(npanel)) + sin(alpha)*(tny(1)+tny(npanel)));
	aidx = aidx+1;
end

%c ----now solve A*ss = b to get the source strengths (ss(1:npanel)) and vortex strength (ss(npanel+1))
%c     Note that your matrix is (npanel+1)
% execute for each alpha
aidx = 1;
for alpha = alphaRangeRad
	ss(:,aidx) = a\b(:,aidx);
	aidx = aidx+1;
end

%c ---- now compute tangential velocity and cp for each panel
aidx = 1;
for alpha = alphaRangeRad
	for i=1:npanel
		xi = 0.5*(x(i)+x(i+1));
		yi = 0.5*(y(i)+y(i+1));
		nsum = 0.0;
		for j=1:npanel+1
			nsum = nsum + at(i,j)*ss(j,aidx);
		end
		vtan = nsum + uinf*(cos(alpha)*tnx(i) + sin(alpha)*tny(i));
		cp(i,aidx) = 1.0 - vtan^2/uinf^2; %Cp
	end
	aidx = aidx+1;
end

% get x midpoints for plotting Cp
for i=1:npanel
	xmid(i) = 0.5*(x(i) + x(i+1));
end

% plot data for -Cp vs x/c
fig1 = figure(1);
hold on;
grid on;
title('Me 163 Komet');
xlabel('x/c');

yyaxis left;
set(gca,{'ycolor'},{'k'});
ylim([-3,10]);
ylabel('-C_{p}');

aidx = 1;
for alpha = alphaRangeDeg
	%plot(x(1:end-1),-cp(:,aidx),'color',colors{aidx},'linestyle','-','marker','none');
	plot(xmid,-cp(:,aidx),'color',colors{aidx},'linestyle','-','marker','none');
	legendInfo{aidx} = sprintf('%d deg.',alpha);
	aidx = aidx+1;
end

% plot airfoil shape
yyaxis right;
set(gca,{'ycolor'},{'k'});
ylim([-0.1,1.5]);
ylabel('y/c');

plot(x,y,'k');
legendInfo{aidx} = 'airfoil';

legend(legendInfo,'location','northeast');

% save plots to jpg
saveas(fig1,fullfile('plots/proj2/',sprintf('proj2_cp_vs_xc_%s.jpg',strrep(airfoilName,' ','_'))));

