% Andrew Navratil, Tony Tran
% MAE 361 Fall 2018
% Final Project - planar n-body problem
% Due 2018-11-28

% referencing Orbital Mechanics for Engineering Students, Curtis for some physical data

% clear all vars and plots
close all; clear all; clc;

% globals to be used in state file
global n m

% step size values
deltaT = 1*3600; % step size (hr * s/hr) [s]
N = 365*2*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)
numFrameSkip = 10;		% only capture every numFrameSkip'th frame, animation code takes awhile

% initial conditions 
% ic = 1: sun/earth/moon
% ic = 2: inner solar system (sun/mercury/venus/earth/mars)
ic = 2;

if ic == 1

n = 3;  % number of bodies
m = zeros(1,n);  % masses
m(1) = 1.9885e30;  % mass of sun [kg]
m(2) = 5.974e24;    % mass of earth [kg]
m(3) = 73.48e21;    % mass of moon [kg]

x(1) = 0;  % sun x init
x(2) = 0;  % sun y init
x(3) = 0;  % earth - x init
x(4) = 1.4960e8;  % earth - y init
x(5) = 0;  % moon - x init
x(6) = x(4) + 3.844e5;  % moon - y init using avg distance to earth [km]

x(7) = 0; % sun x vel init
x(8) = 0; % sun y vel init
x(9) = -29.78;  % earth x vel init - mean orbital velocity [km/s]
x(10) = 0;  % earth y vel init
x(11) = x(9) - 1.022; % moon x vel init - mean orbital velocity of moon [km/s]
x(12) = 0; % moon y vel init

elseif ic == 2

n = 5;  % number of bodies
m = zeros(1,n);  % masses in [kg]
m(1) = 1.9885e30;  % sun
m(2) = 3.302e23;  % mercury
m(3) = 4.869e24;  % venus
m(4) = 5.974e24;  % earth 
m(5) = 6.419e23;  % mars

%http://hyperphysics.phy-astr.gsu.edu/hbase/Solar/soldata2.html
% positions in [km]
x(1) = 0;  % sun x init
x(2) = 0;  % sun y init
x(3) = 0;  % mercury x init
x(4) = 5.79e7; % mercury y init
x(5) = 0;  % venus x init
x(6) = 1.082e8; % venus y init
x(7) = 0;  % earth x init
x(8) = 1.4960e8;  % earth y init
x(9) = 0;  % mars x init
x(10) = 2.279e8;  % mars y init

% velocities in [km/s]
x(11) = 0; % sun x vel init
x(12) = 0; % sun y vel init
x(13) = -47.4;  % mercury x vel init (mean)
x(14) = 0;  % mercury y vel init
x(15) = -35.0;  % venus x vel init (mean)
x(16) = 0;  % venus y vel init
x(17) = -29.8;  % earth x vel init (mean)
x(18) = 0;  % earth y vel init
x(19) = -24.1;  % mars x vel init
x(20) = 0;  % mars y vel init

elseif ic == 3

n = 3;  % number of bodies
m = zeros(1,n);  % masses
m(1) = 1.9885e30;  % star 1
m(2) = 1.9885e30;  % star 2
m(3) = 5.974e24;  % planet 1

x(1) = -2e7;  % star 1 x init
x(2) = 0;  % star 1 y init
x(3) = 2e7;  % star 2 x init
x(4) = 0;  % star 2 y init
x(5) = 0;  % planet 1 x init
x(6) = 5e8;  % planet 1 y init 

x(7) = 0; % star 1 x vel init
x(8) = -50; % star 1 y vel init
x(9) = 0;  % star 2 x vel init 
x(10) = 50;  % star 2 y vel init
x(11) = -20; % planet 1 x vel init 
x(12) = 0; % planet 1 y vel init

elseif ic == 4

n = 3;  % number of bodies
m = zeros(1,n);  % masses
m(1) = 2e30;  % star 1
m(2) = 2e30;  % star 2
m(3) = 2e30;  % star 3

x(1) = -1e7;  % star 1 x init
x(2) = 0;  % star 1 y init
x(3) = 1e7;  % star 2 x init
x(4) = 0;  % star 2 y init
x(5) = 0;  % star 3 x init
x(6) = 0;  % star 3 y init 

x(7) = 125*0.34711; % star 1 x vel init
x(8) = 125*0.53278; % star 1 y vel init
x(9) = x(7);  % star 2 x vel init 
x(10) = x(8);  % star 2 y vel init
x(11) = -2*x(7); % star 3 x vel init 
x(12) = -2*x(8); % star 3 y vel init


end

% main integration loop
% time(i) = vector to hold time values
% xgraph(1:n,i) i = time val, 1:n = x position values for each body at time i
% ygraph(1:n,i) i = time val, 1:n = y position values for each body at time i
for i = 1:N
	t = (i-1)*deltaT;
	time(i) = t;
	
	xgraph(1:n,i) = x(1:2:2*n-1);
	ygraph(1:n,i) = x(2:2:2*n);

	% using RK4 integrator	
	x = rk4('final_state',x,t,deltaT);
end

%if false

% TODO: pick a month and find actual postion values for moon relative to earth
% and plot that next to the numerical simulation

% plot x position vs y position for moon
fig1 = figure(1);
colormap(jet); 
hold on;
grid on;
title(sprintf('%d-body problem: x position vs y position',n));
xlabel('x position (km)');
ylabel('y position (km)');

% enlarge moon positions so we can see it orbit eart
%xgraph(3,:) = xgraph(3,:) * 1.1;
%ygraph(3,:) = ygraph(3,:) * 1.1;

for i = 1:n
	plot(xgraph(i,:),ygraph(i,:),'.-');
end
%legend('sun','earth','moon');

%end

%if false

% animation
figure;
%hold on;
writerObj = VideoWriter('nbodyEarthMoonSun.avi');
%writerObj.FrameRate = 1/(deltaT*numFrameSkip);
%writerObj.FrameRate = 30;
writerObj.FrameRate = N/(30*numFrameSkip);  % N / desired length of movie in sec
open(writerObj);
for i = 1:numFrameSkip:N
	for j = 1:n
		plot(xgraph(j,i),ygraph(j,i),'.','markersize',50);
		if j==1	hold on; end
	end

	if ic == 4
		axis([-1.5e7 1.5e7 -1.5e7 1.5e7]);
	else
		axis([-2.5e8 2.5e8 -2.5e8 2.5e8]);
	end
	
	M = getframe;
	writeVideo(writerObj,M);
	delete(findobj(gca, 'type', 'marker'));
	hold off;
end

movie(M);
close(writerObj);

%end
