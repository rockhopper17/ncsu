% Andrew Navratil
% MAE 252 Spring 2018
% Project 2: Hess-Smith Panel Method
% Due 2018-05-07

% clear all vars and plots
close all; clear all; clc;

%c ----- import panel coordinates (x, y (1:npanel+1))
%c ----- Note:  ordering must be from bottom trailing edge to top trailing edge (clockwise)

%airfoilName = 'ME163 Komet';
%fid = fopen('data/me163-panel');  % don't forget to comment out flipud's below for this
%data = cell2mat(textscan(fid,'%f%f','headerlines',1));
%fclose(fid);
%fid = fopen('data/me163-camber');
%dataCamber = cell2mat(textscan(fid,'%f%f%f','headerlines',1)); % comment out camber calcs below for this
%fclose(fid);

%airfoilName = 'NACA 0010';
%fid = fopen('data/naca0010.dat');
%data = cell2mat(textscan(fid,'%f%f','headerlines',1));
%fclose(fid);

airfoilName = 'Prandtl-D';
fid = fopen('data/prandtl-d-root.dat');
data = cell2mat(textscan(fid,'%f%f','headerlines',1));
fclose(fid);

%airfoilName = 'Dolphin';
%fid = fopen('data/dolphin5.dat');
%data = cell2mat(textscan(fid,'%f%f'));
%fclose(fid);

% variables
alphaRangeDeg = -5:1:15;	% angle of attack range for calculations
alphaRangeRad = alphaRangeDeg*pi/180.0;
uinf = 50;					% freestream velocity (m/s)
%pi = 4.0*atan(1.0)

% pull out x and y coords
x = data(:,1);
y = data(:,2);
% for NACA 0010 and prandtl-d need to reorder
x = flipud(x);
y = flipud(y);
npanel = numel(x)-1;

%-------------------------------------------------------------------------
% Panel Method calculations (modified from Edwards)
%-------------------------------------------------------------------------
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

%-------------------------------------------------------------------------
% CL calculations
%-------------------------------------------------------------------------

% calculate Cl from panel method technique using computed circulation distribution (Kutta-Joukowski)
dsTotal = sum(ds);	% total surface path length around airfoil
aidx = 1;
for alpha = alphaRangeRad
	% gamma (vortex strength) is ss(npanel+1, alpha idx)
	% using formula from notes on Apr 4
	clPanel(aidx) = 2*ss(end,aidx)*dsTotal/uinf;
	aidx = aidx+1;
end

% calculate Cl from thin airfoil theory using camber line

% me163-camber file import
%xcam = dataCamber(:,1);
%ycam = dataCamber(:,2);
%thetacam = dataCamber(:,3);

% airfoil specific settings
[C,ia,idx] = unique(x,'rows');
xcam = C;   % x values are the same for upper and lower
ycam = accumarray(idx,y,[],@mean);  % average y value pairs at each x

% dolphin specific settings
%xcam = x(1:38);
%ycam = 0.5*(y(1:38)+y(76:-1:39));

thetacam = acos(1.0 - 2.0*xcam);
npanelcam = numel(xcam) - 1;

aidx = 1;
for alpha = alphaRangeRad
	csum = 0.0;
	for i=1:npanelcam
		df = (ycam(i+1)-ycam(i))/(xcam(i+1)-xcam(i));
		c2 = -2.0 * (0.5*(xcam(i)+xcam(i+1)));
		dtheta = thetacam(i+1) - thetacam(i);
		csum = csum + (df*c2*dtheta);
	end
	clTat(aidx) = 2*pi*(alpha + csum/pi);
	aidx = aidx+1;
end

% get midpoints for plotting Cp and as origin points for vortex, source
for i=1:npanel
	xmid(i) = 0.5*(x(i) + x(i+1));
	ymid(i) = 0.5*(y(i) + y(i+1));
end

%-------------------------------------------------------------------------
% Plot -Cp vs x/c, CL vs alpha
%-------------------------------------------------------------------------
fig1 = figure(1);
hold on;
grid on;
title(sprintf('Cp vs x/c for %s',airfoilName));
xlabel('x/c');

yyaxis left;
set(gca,{'ycolor'},{'k'});
%ylim([-max(max(cp))-2,-min(min(cp))+1]);
%ylim([-2 20]);

% dolphine specific settings
%ylim([-200 150]);

% airfoil settings
ylim([-4 15]);

ylabel('-C_{p}');

colors = {'k','b','g',[.75 0 .75],'r'};
aidx = 1;
cidx = 1;
for alpha = -5:5:15
	plot(xmid,-cp(:,aidx),'color',colors{cidx},'linestyle','-','marker','none');
	legendInfo{cidx} = sprintf('%d deg.',alpha);
	aidx = aidx+5;
	cidx = cidx+1;
end

% plot airfoil shape
yyaxis right;
set(gca,{'ycolor'},{'k'});
ylim([-0.1,1.5]);
ylabel('y/c');

plot(x,y,'k');
%plot(xcam,ycam,'r--');
legendInfo{cidx} = 'airfoil';

legend(legendInfo,'location','northeast');

saveas(fig1,fullfile('plots/proj2/',sprintf('proj2_cp_vs_xc_%s.jpg',strrep(airfoilName,' ','_'))));

% plot data for Cl vs alpha
fig2 = figure(2);
hold on;
grid on;
title(sprintf('C_{L} vs %s for %s','\alpha',airfoilName));
xlabel('\alpha (deg.)')
ylabel('C_{L}');
plot(alphaRangeDeg,clTat,'k',alphaRangeDeg,clPanel,'r');
legend('TAT','Panel Method','location','southeast');

saveas(fig2,fullfile('plots/proj2/',sprintf('proj2_cl_vs_alpha_%s.jpg',strrep(airfoilName,' ','_'))));

%-------------------------------------------------------------------------
% Velocity Magnitude Contours
%-------------------------------------------------------------------------
% variables
alphavelDeg = 15;			% angle of attack in deg for use in velocity mag contour plot
alphavelRad = alphavelDeg*pi/180.0;
aidxvel = 21;				% index into ss, must match alphavelDeg col (alpha=-5 -> idx=1,.. alpha=0 -> idx=6)

% airfoil specific settings
xoffset = 1.0;				% x offset distance to put airfoil in middle of vel grid
yoffset = 0.75;				% y offset distance to put airfoil in middle of vel grid
xr = linspace(0,3,200);		% x points for grid
yr = linspace(0,1.5,100);		% y points for grid

% dolphin specific settings
%xoffset = 1.0;				% x offset distance to put airfoil in middle of vel grid
%yoffset = 1.0;				% y offset distance to put airfoil in middle of vel grid
%xr = linspace(0,3,200);		% x points for grid
%yr = linspace(0,2.5,100);		% y points for grid

[xgrid,ygrid] = meshgrid(xr,yr);	% meshgrid for calculating z values

% add offset to midpoints to center airfoil in grid
xmidvel = xmid + xoffset;
ymidvel = ymid + yoffset;

% elementary flow velocities in cartesian (u = vel x, v = vel y)
uUniform = @(alpha) uinf*cos(alpha);
vUniform = @(alpha) uinf*sin(alpha);
uSrcVortex = @(xip,yip,plen) 0.5/pi*(atan2(yip,xip-plen)-atan2(yip,xip)); 
vSrcVortex = @(xip,yip,plen) 0.25/pi*log(((xip-plen).^2 + yip.^2)./(xip.^2 + yip.^2));

% calculate velocities and streamlines for panels
uTotal = [xgrid*0];
vTotal = [xgrid*0];

% use panel method logic to calculate velocities and corresponding streamlines
for j=1:npanel
	xip =  tnx(j)*(xgrid-xmidvel(j)) + tny(j)*(ygrid-ymidvel(j));  %x* location in panel coord. system          
	yip = -tny(j)*(xgrid-xmidvel(j)) + tnx(j)*(ygrid-ymidvel(j));  %y* location in panel coord. system
	upv = uSrcVortex(xip,yip,ds(j));
	vpv = vSrcVortex(xip,yip,ds(j));
	%if (i==j) % to do: will we run into this issue using grid points? probably not..
		%upv = 0.5;
		%vpv = 0.0;
	%end
	uv = tnx(j)*upv - tny(j)*vpv;  %x component of induced velocity in Cart. system
	vv = tny(j)*upv + tnx(j)*vpv;  %y component of induced velocity in Cart. system
	us = -vv; %x component of source velocity
	vs =  uv; %y component of source velocity

	uTotal = uTotal + (ss(end,aidxvel)*uv) + (ss(j,aidxvel)*us);
	vTotal = vTotal + (ss(end,aidxvel)*vv) + (ss(j,aidxvel)*vs);
end

% add uniform vel
uTotal = uTotal + uUniform(alphavelRad);
vTotal = vTotal + vUniform(alphavelRad);
velTotal = sqrt(uTotal.^2 + vTotal.^2);

% calculate streamlines

% airfoil specific settings
startx = [zeros(15,1);linspace(0,3,10)'];
starty = [linspace(0,1.5,15)';zeros(10,1)];

% dolphin specific settings
%startx = [zeros(15,1);linspace(0,3,10)'];
%starty = [linspace(0,2.5,15)';zeros(10,1)];

psiTotal = stream2(xgrid,ygrid,uTotal,vTotal,startx,starty);

% plot velocity magnitude contours
fig3 = figure(3);
colormap('jet');
velBins = linspace(0,2,200);
[C,h] = contourf(xgrid,ygrid,velTotal/uinf,velBins);
set(h,'LineStyle','none');
c = colorbar;
c.Label.String = 'u_{mag} / u_{\infty}';
title(sprintf('Velocity Magnitude Contours at %s = %d deg. for  %s','\alpha',alphavelDeg,airfoilName));
caxis([0 2]);
pbaspect([2 1 1]);
hold on;
h = streamline(psiTotal);		% streamlines
set(h,'color','k');
fill(x+xoffset,y+yoffset,'w');  % airfoil body

saveas(fig3,fullfile('plots/proj2/',sprintf('proj2_velmag_%s.jpg',strrep(airfoilName,' ','_'))));

