% Andrew Navratil
% MAE 252 Aero I Spring 2018
% Project 1: Plot streamlines and velocity magnitudes for elementary function combos
% Due 2018-04-02

% clear all vars and plots
close all; clear all; clc;

%=====================================================================
% Rankine Half Oval
%=====================================================================

% variables
vInf = 50;					% freestream velocity (m/s)
lambda = 50;				% source / sink strenth
b = 2;						% distance between sources
x0 = 1;						% x center coord
y0 = .5;					% y center coord
xr = linspace(0,2,200);		% x points for grid
yr = linspace(0,1,100);		% y points for grid
[x,y] = meshgrid(xr,yr);	% meshgrid for calculating z values
stagLine = lambda/2;		% stagnation line psi value

colormap(winter);

% streamlines
psi = vInf * (y - y0) + (lambda / (2 * pi)) * atan2(y - y0, x - x0);
idxBody = abs(psi) < stagLine;
psi(idxBody) = 0;

% velocity
u = (lambda / (2 * pi)) * ((x - x0) ./ ((x - x0).^2 + (y - y0).^2)) + vInf;
v = (lambda / (2 * pi)) * ((y - y0) ./ ((x - x0).^2 + (y - y0).^2));
velMag = sqrt(u.^2 + v.^2);
velMag(idxBody) = -1;
velBins = [-1 0 .25*vInf .5*vInf .75*vInf vInf 1.25*vInf 1.5*vInf];
%velBins = linspace(0,1.5*vInf,7);

% plot
fig1 = figure(1);
[C,h] = contourf(x,y,velMag,velBins);
clabel(C,h);
pbaspect([2 1 1]);
hold on;
contour(x,y,psi,25,'k->');

% save plots to jpg
%saveas(fig1,'halfOval.jpg');

%=====================================================================
% Rankine Full Oval
%=====================================================================

% variables
vInf = 50;					% freestream velocity (m/s)
lambda = 50;				% source / sink strenth
b = .25;					% distance between source/sink and center
x01 = 1.25;					% x center coord sink
y01 = .5;					% y center coord sink
x02 = .75;					% x center coord source
y02 = .5;					% y center coord source
xr = linspace(0,2,200);		% x points for grid
yr = linspace(0,1,100);		% y points for grid
[x,y] = meshgrid(xr,yr);	% meshgrid for calculating z values
stagLine = 0;				% stagnation line psi value

colormap(winter);

% streamlines
psi = vInf * (y - y0) + (lambda / (2 * pi)) * ( atan2(y - y02, x - x02) - atan2(y - y01, x - x01));
psiTop = psi(1:50,:);
psiBottom = psi(51:end,:);
idxBodyTop = psiTop > (stagLine+0.0001);
idxBodyBottom = psiBottom < (stagLine+0.0001);
psiTop(idxBodyTop) = 0;
psiBottom(idxBodyBottom) = 0;
psi2 = [psiTop;psiBottom];
%idxBody = psi(psi(100:end,50:end) < stagLine);
%idxBody = psi(1:99,1:49) > stagLine;
%psi(idxBody) = 0;

% velocity
u = ((lambda / (2 * pi)) * ((x - x02) ./ ((x - x02).^2 + (y - y02).^2))) -...
((lambda / (2 * pi)) * ((x - x01) ./ ((x - x01).^2 + (y - y01).^2))) + vInf;
v =  (lambda / (2 * pi)) * ((y - y02) ./ ((x - x02).^2 + (y - y02).^2)) -...
(lambda / (2 * pi)) * ((y - y01) ./ ((x - x01).^2 + (y - y01).^2));
velMag = sqrt(u.^2 + v.^2);
%velMag(idxBody) = -1;
velBins = [-1 0 .25*vInf .5*vInf .75*vInf vInf 1.25*vInf 1.5*vInf];
velBins = linspace(0,1.5*vInf,7);

% plot
fig2 = figure(2);
[C,h] = contourf(x,y,velMag,velBins);
clabel(C,h);
pbaspect([2 1 1]);
hold on;
contour(x,y,psi,25,'k->');

%=====================================================================
% Nonlifting Cylinder
%=====================================================================

% variables
vInf = 50;					% freestream velocity (m/s)
R = .25;					% radius of stagnation streamline
x0 = 1;						% x center coord sink
y0 = .5;					% y center coord sink
xr = linspace(0,2,200);		% x points for grid
yr = linspace(0,1,100);		% y points for grid
[x,y] = meshgrid(xr,yr);	% meshgrid for calculating z values
stagLine = 0;				% stagnation line psi value
eps = 1e-6;					% small value to avoid a divide by zero

colormap(winter);

% streamlines
psi = vInf * (y - y0) .* (1 - (R.^2 ./ ( (x-x0).^2 + (y-y0).^2 + eps^2 )));
psiTop = psi(1:50,:);
psiBottom = psi(51:end,:);
idxBodyTop = psiTop > stagLine;
idxBodyBottom = psiBottom < stagLine;
psiTop(idxBodyTop) = -1;
psiBottom(idxBodyBottom) = -1;
psi2 = [psiTop;psiBottom];
psiZero = psi(psi == 0);
%idxBody = psi < stagLine;
%psi(idxBody) = 0;
%idxBodyTop = psiTop > (stagLine+0.0001);
%psiTop(idxBodyTop) = 0;
%psi2 = [psiTop;psiBottom];
%idxBody = psi(psi(100:end,50:end) < stagLine);
%idxBody = psi(1:99,1:49) > stagLine;
%psi(idxBody) = 0;

% velocity
u = vInf * 2;
v = (vInf * (-2) * (x - x0) .* (y - y0) * R.^2) ./ (( (x-x0).^2 + (y-y0).^2 + eps^2 ).^2);
velMag = sqrt(u.^2 + v.^2);
%velMag(idxBody) = -1;
velBins = [-1 0 .25*vInf .5*vInf .75*vInf vInf 1.25*vInf 1.5*vInf];
velBins = linspace(0,1.5*vInf,7);

% plot
fig3 = figure(3);
[C,h] = contourf(x,y,velMag,velBins);
clabel(C,h);
pbaspect([2 1 1]);
hold on;
[C,h] = contour(x,y,psi,50,'k->');
clabel(C,h);

