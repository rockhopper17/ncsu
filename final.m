% Andrew Navratil, Tony Tran
% MAE 361 Fall 2018
% Final Project - planar n-body problem
% Due 2018-11-28

% referencing Orbital Mechanics for Engineering Students, Curtis for some physical data

% clear all vars and plots
close all; clear all; clc;

% set some colors
colormap('autumn');
colors = get(gca,'colororder');

% globals to be used in state file
global n m G

% universal gravitational constant [km^3/kg/s^2]
G = 6.67259e-20;      

% default step size values, sometimes modified in the ic scenariois
deltaT = 1*3600; % step size (hr * s/hr) [s]
N = 2*365*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)

% only capture every numFrameSkip'th frame, animation code takes awhile
%numFrameSkip = 100;  % default number of frames to skip
% base the frame rate on the inner sol and calculate others to match this
% 30 seconds for each scenario
%frate = N/(30*numFrameSkip);
frate = 30;  % frame rate for movie file
runtime = 20;  % default num seconds to run each scenario
numframes = frate * runtime;  % total number of frames to capture

% ****************************************************************************************
% initial conditions 
% ****************************************************************************************
% ic = 1: sun/earth/moon
% ic = 2: inner solar system (sun/mercury/venus/earth/mars)
% ic = 3: 3 body - 2 stars orbiting each other + 1 planet orbiting way out
% ic = 4: 3body figure 8s w real m,G values (blows up sometime after 60 days)
% ic = 5: 3body periodic solns w m=1, G=1
% ic = 6: multiple solar systems interacting
% ****************************************************************************************
movienames = {'SunEarthMoon','innersol','3body1planet','3bodyFig8Real',...
    '3bodyFig8G1','multiplesols'};  % used for plot title

%ic = 2;  % set which scenario to execute ***********
iclist = [2 5];  % list of scenarios to execute in order (for presentation)
makemovie = true; % set this to true for writing out a movie file

% loop scenarios to concatenate a movie file, lookup in the iclist
for icidx = 1:length(iclist)

ic = iclist(icidx);  % set which scenario to execute currently

if makemovie == true
	% animation - open movie file now so we can concatenate multiple scenarios
	%writerObj = VideoWriter(char(movienames(ic)));
	writerObj = VideoWriter('Navratil-Tran-ThreeBodyPblmOrbits.avi');
	%writerObj.FrameRate = 1/(deltaT*numFrameSkip);
	%writerObj.FrameRate = 30;
	writerObj.FrameRate = frate;  % N / desired length of movie in sec
	open(writerObj);
end

% switch on ic (initial conditions) for different scenarios
if ic == 1

	n = 3;  % number of bodies
	m = zeros(1,n);  % masses
	x = zeros(1,4*n);  % state space variables

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
	x = zeros(1,4*n);  % state space variables
	
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

	deltaT = 1*3600; % step size (hr * s/hr) [s]
	N = 2*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)

	n = 3;  % number of bodies
	
	m = zeros(1,n);  % masses
	x = zeros(1,4*n);  % state space variables
	
	km(1) = 1.9885e30;  % star 1
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

	deltaT = 1*3600; % step size (hr * s/hr) [s]
	N = 60*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)

	n = 3;  % number of bodies
	
	m = zeros(1,n);  % masses
	x = zeros(1,4*n);  % state space variables
	
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

elseif ic == 5

	% this uses the data for 3-body orbits
	% where G = 1
	% http://three-body.ipb.ac.rs/

	% figure 8
	p1 = 0.347111
	p2 = 0.532728
	T = 6.32449

	% butterfly (1)
	%p1 = 0.415251
	%p2 = 0.291346
	%T = 47.925856

	% butterfly (another one)
	%p1 = 0.184279
	%p2 = 0.587188
	%T = 63.534541

	G = 1;
	deltaT = 0.1; % step size (hr * s/hr) [s]
	N = T*100/deltaT;  % num steps days * (hrs/day * s/hr)
	numFrameSkip = 1; % only capture every numFrameSkip'th frame, animation code takes awhile

	n = 3;  % number of bodies
	m = zeros(1,n);  % masses
	x = zeros(1,4*n);  % state space variables
	
	m(1) = 1;  % star 1
	m(2) = 1;  % star 2
	m(3) = 1;  % star 3

	x(1) = -1;  % star 1 x init
	x(2) = 0;  % star 1 y init
	x(3) = 1;  % star 2 x init
	x(4) = 0;  % star 2 y init
	x(5) = 0;  % star 3 x init
	x(6) = 0;  % star 3 y init 

	x(7) = p1; % star 1 x vel init
	x(8) = p2; % star 1 y vel init
	x(9) = p1;  % star 2 x vel init 
	x(10) = p2;  % star 2 y vel init
	x(11) = -2*p1; % star 3 x vel init 
	x(12) = -2*p2; % star 3 y vel init

elseif ic == 6

	deltaT = 12*3600; % step size (hr * s/hr) [s]
	N = 365*35*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)
	numFrameSkip = 100;		% only capture every numFrameSkip'th frame, animation code takes awhile

	n = 5*3;  % number of bodies
	m = zeros(1,n);  % masses in [kg]
	x = zeros(1,4*n);  % state space variables
	
	m(1) = 1.9885e30;  % sun
	m(2) = 3.302e23;  % mercury
	m(3) = 4.869e24;  % venus
	m(4) = 5.974e24;  % earth 
	m(5) = 6.419e23;  % mars

	m(6:10) = m(1:5);
	m(11:15) = m(1:5);
	%m(16:20) = m(1:5);
	%m(21:25) = m(1:5);

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

	posoff = 5e9;
	x(11:20) = x(1:10) + posoff;
	x(21:2:29) = x(1:2:9) - posoff;
	x(22:2:30) = x(2:2:10) + posoff;
	%x(31:2:39) = x(1:2:9) - posoff;
	%x(32:2:40) = x(2:2:10) - posoff;
	%x(41:2:49) = x(1:2:9) + posoff;
	%x(42:2:50) = x(2:2:10) - posoff;

	% velocities in [km/s]
	x(2*n+1) = 0; % sun x vel init
	x(2*n+2) = 0; % sun y vel init
	x(2*n+3) = -47.4;  % mercury x vel init (mean)
	x(2*n+4) = 0;  % mercury y vel init
	x(2*n+5) = -35.0;  % venus x vel init (mean)
	x(2*n+6) = 0;  % venus y vel init
	x(2*n+7) = -29.8;  % earth x vel init (mean)
	x(2*n+8) = 0;  % earth y vel init
	x(2*n+9) = -24.1;  % mars x vel init
	x(2*n+10) = 0;  % mars y vel init

	veloff = 2;
	x(2*n+11:2*n+20) = x(2*n+1:2*n+10) - veloff;
	x(2*n+21:2:2*n+29) = x(2*n+1:2:2*n+9) + veloff;
	x(2*n+22:2:2*n+30) = x(2*n+2:2:2*n+10) - veloff;
	%x(2*n+31:2:2*n+39) = x(2*n+1:2:2*n+9) + veloff;
	%x(2*n+32:2:2*n+40) = x(2*n+2:2:2*n+10) + veloff;
	%x(2*n+41:2:2*n+49) = x(2*n+1:2:2*n+9) - veloff;
	%x(2*n+42:2:2*n+50) = x(2*n+2:2:2*n+10) + veloff;

end

% ****************************************************************************************
% main integration loop
% ****************************************************************************************
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

% ****************************************************************************************
% plot x position vs y position
% ****************************************************************************************
figure;
hold on;
grid on;
%title(sprintf('%d-body problem: x position vs y position',n));
title(char(movienames(ic)));
xlabel('x position (km)');
ylabel('y position (km)');

% enlarge moon positions so we can see it orbit eart
%xgraph(3,:) = xgraph(3,:) * 1.1;
%ygraph(3,:) = ygraph(3,:) * 1.1;

if ic==2222222
	% inner solar system
	plot(xgraph(1,:),ygraph(1,:),'.','markersize',50,'color','yellow');
	plot(xgraph(2,:),ygraph(2,:),'.-','color','magenta');	
	plot(xgraph(3,:),ygraph(3,:),'.-','color','green');	
	plot(xgraph(4,:),ygraph(4,:),'.-','color','blue');	
	plot(xgraph(5,:),ygraph(5,:),'.-','color','red');	
	
	legend('sun','mercury','venus','earth','mars');
else
	for i = 1:n
		plot(xgraph(i,:),ygraph(i,:),'.-');
	end
end

set(gca,'color','black');
if ic == 4
	axis([-1.5e7 1.5e7 -1.5e7 1.5e7]);
elseif ic == 5
	axis([-1.5 1.5 -1.5 1.5]);
elseif ic == 6
	axis([-1.5e10 1.5e10 -1e9 6e9]);
else
	axis([-2.5e8 2.5e8 -2.5e8 2.5e8]);
end
drawnow;

% ****************************************************************************************
% animation code
% ****************************************************************************************
if makemovie == true
	% setup plot
	figure;
	hold on;
	if ic == 4
		axis([-1.5e7 1.5e7 -1.5e7 1.5e7]);
	elseif ic == 5
		axis([-1.5 1.5 -1.5 1.5]);
	elseif ic == 6
		axis([-1.5e10 1.5e10 -1e9 6e9]);
	else
		axis([-2.5e8 2.5e8 -2.5e8 2.5e8]);
	end

	set(gca,'color','black');

	% first plot all the discs and just change their positions later on
	for j = 1:n
		p(j) = plot(xgraph(j,1),ygraph(j,1),'.','markersize',50);
		%if j==1
			%%p(j) = plot(xgraph(j,1),ygraph(j,1),'.','markersize',50,'color',colors(1,:));
			%p(j) = plot(xgraph(j,1),ygraph(j,1),'.','markersize',50,'color','red');
		%elseif j==2
			%p(j) = plot(xgraph(j,1),ygraph(j,1),'.g','markersize',50,'color','green');
		%elseif j==3
			%p(j) = plot(xgraph(j,1),ygraph(j,1),'.b','markersize',50,'color','blue');
		%else
			%p(j) = plot(xgraph(j,1),ygraph(j,1),'.','markersize',50);
		%end
	end

	% start at 1*numFrameSkip, first point already plotted
	% now plot all the orbit lines following the discs so the orbits are created as the disc moves
	% keep the same colors used above for the first few discs
	numFrameSkip = floor(N/numframes);
	for i = numFrameSkip:numFrameSkip:numframes*numFrameSkip
		for j = 1:n
			plot(xgraph(j,1:numFrameSkip:i),ygraph(j,1:numFrameSkip:i),'-w');
			%if j==1
				%plot(xgraph(j,1:numFrameSkip:i),ygraph(j,1:numFrameSkip:i),'-r');
			%elseif j==2
				%plot(xgraph(j,1:numFrameSkip:i),ygraph(j,1:numFrameSkip:i),'-g');
			%elseif j==3
				%plot(xgraph(j,1:numFrameSkip:i),ygraph(j,1:numFrameSkip:i),'-b');
			%else
				%plot(xgraph(j,1:numFrameSkip:i),ygraph(j,1:numFrameSkip:i),'-');
			%end

			p(j).XData = xgraph(j,i);
			p(j).YData = ygraph(j,i);
			drawnow;
		end
		
		M = getframe;
		writeVideo(writerObj,M);
		%hold off;
	end

end  % end animation code

end % end ic iteration

if makemovie == true
	movie(M);
	close(writerObj);
end


