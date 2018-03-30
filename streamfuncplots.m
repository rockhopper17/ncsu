% Andrew Navratil
% MAE 252 Aero I Spring 2018
% Project 1: Plot streamlines and velocity magnitudes for elementary function combos
% Due 2018-04-02

% clear all vars and plots
close all; clear all; clc;

% variables
vInf = 50;					% freestream velocity (m/s)
lambda = 50;				% source / sink strength
b = .25;					% distance from center to source / sink
R = .25;					% cylinder radius where R^2 = kappa / (2pi vInf);
circ = 4*pi*vInf*R-50;		% circulation
xc = 1;						% x center coord
yc = .5;					% y center coord
xr = linspace(0,2,200);		% x points for grid
yr = linspace(0,1,100);		% y points for grid
[x,y] = meshgrid(xr,yr);	% meshgrid for calculating z values

% elementary flow streamfunctions in cartesian (x,y)
psiUniform = @(y0) vInf * (y-y0);
psiSource = @(x0,y0) (lambda/(2*pi)) * atan2(y-y0, x-x0);
psiDoublet = @(x0,y0) (-R^2 * vInf * (y-y0)) ./ ( (x-x0).^2 + (y-y0).^2);
psiVortex = @(x0,y0) (circ/(2*pi)) * log(sqrt((x-x0).^2 + (y-y0).^2));

% elementary flow velocities in cartesian (u = vel x, v = vel y)
uUniform = vInf;
vUniform = 0;
uSource = @(x0,y0) (lambda/(2*pi)) * ( (x-x0) ./ ( (x-x0).^2 + (y-y0).^2 ) );
vSource = @(x0,y0) (lambda/(2*pi)) * ( (y-y0) ./ ( (x-x0).^2 + (y-y0).^2 ) );
uDoublet = @(x0,y0) (R^2 * vInf * ((y-y0).^2 - (x-x0).^2)) ./ ( (x-x0).^2 + (y-y0).^2 ).^2;
vDoublet = @(x0,y0) (-2 * R^2 * vInf * (x-x0) .* (y-y0)) ./ ( (x-x0).^2 + (y-y0).^2 ).^2;
uVortex = @(x0,y0) (circ * (y-y0)) ./ ( 2*pi * ( (x-x0).^2 + (y-y0).^2 ) );
vVortex = @(x0,y0) (-circ * (x-x0)) ./ ( 2*pi * ( (x-x0).^2 + (y-y0).^2 ) );

% flow combination streamlines
psiHalfOval = psiUniform(yc) + psiSource(xc,yc);
psiFullOval = psiUniform(yc) + psiSource(xc-b,yc) - psiSource(xc+b,yc);
psiNonliftCylinder = psiUniform(yc) + psiDoublet(xc,yc);
psiLiftCylinder = psiUniform(yc) + psiDoublet(xc,yc) + psiVortex(xc,yc);
psiRandom1 = psiUniform(yc) + psiSource(xc-b,yc+.25*b) - psiSource(xc+2*b,yc+.25*b) + psiVortex(xc,yc)...
	+ psiSource(xc-.25*b,yc-.25*b) - psiSource(xc+.25*b,yc-.25*b);
psiRandom2 = psiUniform(yc) + psiSource(xc-b,yc) - psiSource(xc+b,yc+b) - psiSource(xc+b,yc-b)...
	+ psiVortex(xc,yc+.25*b) - psiVortex(xc,yc-.25*b);

% flow combintation velocities
velHalfOval = sqrt( (uUniform + uSource(xc,yc)).^2 + (vUniform + vSource(xc,yc)).^2 );
velFullOval = sqrt( (uUniform + uSource(xc-b,yc) - uSource(xc+b,yc)).^2 +...
	(vUniform + vSource(xc-b,yc) - vSource(xc+b,yc)).^2 );
velNonliftCylinder = sqrt( (uUniform + uDoublet(xc,yc)).^2 + (vUniform + vDoublet(xc,yc)).^2 );
velLiftCylinder = sqrt( (uUniform + uDoublet(xc,yc) + uVortex(xc,yc) ).^2 +...
	(vUniform + vDoublet(xc,yc) + vVortex(xc,yc) ).^2 );
velRandom1 = sqrt( (uUniform + uSource(xc-b,yc+.25*b) - uSource(xc+2*b,yc+.25*b) + uVortex(xc,yc)...
	+ uSource(xc-.25*b,yc-.25*b) - uSource(xc+.25*b,yc-.25*b)).^2 + ...
	(vUniform + vSource(xc-b,yc+.25*b) - vSource(xc+2*b,yc+.25*b) + vVortex(xc,yc)...
	+ vSource(xc-.25*b,yc-.25*b) - vSource(xc+.25*b,yc-.25*b)).^2);
velRandom2 = sqrt( (uUniform + uSource(xc-b,yc) - uSource(xc+b,yc+b) - uSource(xc+b,yc-b)...
	+ uVortex(xc,yc+.25*b) - uVortex(xc,yc-.25*b)).^2 + ...
	(vUniform + vSource(xc-b,yc) - vSource(xc+b,yc+b) - vSource(xc+b,yc-b)...
	+ vVortex(xc,yc+.25*b) - vVortex(xc,yc-.25*b)).^2);

if false

% plot half oval
fig1 = figure(1);
colormap(jet);
velBins = linspace(0,2*vInf,50);
velBinLabels = [0 26.5306 51.0204 75.5102 100];
[C,h] = contourf(x,y,velHalfOval,velBins);
set(h,'LineStyle',':','Color','k');
clabel(C,h,velBinLabels);
pbaspect([2 1 1]);
hold on;
contour(x,y,psiHalfOval,25,'k-');
stagLineIdx = psiHalfOval(abs(psiHalfOval) >= (lambda/2 - 0.1) & abs(psiHalfOval) <= (lambda/2 + 0.1));
contour(x,y,psiHalfOval,stagLineIdx,'k-','Color','b','LineWidth',2);

% plot full oval
fig2 = figure(2);
colormap(jet);
velBins = linspace(0,2*vInf,50);
velBinLabels = [0 26.5306 51.0204 75.5102 100];
[C,h] = contourf(x,y,velFullOval,velBins);
set(h,'LineStyle',':','Color','k');
clabel(C,h,velBinLabels);
pbaspect([2 1 1]);
hold on;
contour(x,y,psiFullOval,25,'k-');
stagLineIdx = psiFullOval(abs(psiFullOval) >= (0 - 0.1) & abs(psiFullOval) <= (0 + 0.1));
contour(x,y,psiFullOval,stagLineIdx,'k-','Color','b','LineWidth',2);

% plot nonlifting cylinder
fig3 = figure(3);
colormap(jet);
velBins = linspace(0,3*vInf,25);
velBinLabels = [0 25 50 75 100];
[C,h] = contourf(x,y,velNonliftCylinder,velBins);
set(h,'LineStyle',':','Color','k');
clabel(C,h,velBinLabels);
pbaspect([2 1 1]);
hold on;
contour(x,y,psiNonliftCylinder,125,'k-');
%stagLineIdx = psiNonliftCylinder(abs(psiNonliftCylinder) >= (0 - 0.1) & abs(psiNonliftCylinder) <= (0 + 0.1));
%contour(x,y,psiNonliftCylinder,stagLineIdx,'k-','LineWidth',2);
viscircles([xc,yc],R,'Color','b','LineWidth',2);

% plot lifting cylinder
fig4 = figure(4);
colormap(jet);
velBins = linspace(0,3*vInf,25);
velBinLabels = [0 25 50 75 100];
[C,h] = contourf(x,y,velLiftCylinder,velBins);
set(h,'LineStyle',':','Color','k');
clabel(C,h,velBinLabels);
pbaspect([2 1 1]);
hold on;
contour(x,y,psiLiftCylinder,200,'k-');
viscircles([xc,yc],R,'Color','b','LineWidth',2);

% plot random 1
fig5 = figure(5);
colormap(jet);
velBins = linspace(0,4*vInf,50);
[C,h] = contourf(x,y,velRandom1,velBins);
set(h,'LineStyle',':','Color','k');
pbaspect([2 1 1]);
hold on;
contour(x,y,psiRandom1,25,'k-');

end

% plot random 2
fig6 = figure(6);
colormap(jet);
velBins = linspace(0,4*vInf,50);
[C,h] = contourf(x,y,velRandom2,velBins);
set(h,'LineStyle','none');
c = colorbar;
c.Label.String = 'velocity (m/s)';
title('Random combination (2), v_{\infty} = 50, \Lambda = 50');
pbaspect([2 1 1]);
hold on;
contour(x,y,psiRandom2,50,'k-');

% save plots to jpg
%saveas(fig1,'halfOval.jpg');

