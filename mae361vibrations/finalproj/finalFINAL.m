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
%numFrameSkip = 25;  % default number of frames to skip
%numFrameSkipMult = 1;  % default multiplier on number of frames to skip
% base the frame rate on the inner sol and calculate others to match this
% 30 seconds for each scenario
runtime = 20;  % default num seconds to run each scenario
%frate = N/(30*numFrameSkip);  % frame rate
frate = 60;  % frame rate for movie file, hard coded so all match when concatenating
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
    '3bodyFig8G1','multiplesols','BlackHole'};

%iclist = [2 5];  % list of scenarios to execute in order (for presentation)

% loop scenarios to concatenate a movie file, lookup in the iclist
% doing this in vlc now, just manually do one scenario at a time
%for icidx = 1:length(iclist)
%ic = iclist(icidx);  % set which scenario to execute currently

ic = 7;  % set which scenario to execute ***********

makemovie = true; % set this to true for writing out a movie file

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

	%numFrameSkip = 25;

	n = 6;  % number of bodies total
	numbodies = 6;  % num unique bodies
	m = zeros(1,n);  % masses in [kg]
	x = zeros(1,4*n);  % state space variables
	
	m(1) = 1.9885e30;  % sun
	m(2) = 3.302e23;  % mercury
	m(3) = 4.869e24;  % venus
	m(4) = 5.974e24;  % earth 
	m(5) = 6.419e23;  % mars
	m(6) = 358;  % mars

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
	x(10) = -2.279e8;  % mars y init
	x(11) = 0;  % rocket x init (on earth)
	x(12) = 1.4960e8;  % rocket y init (on earth)

	% velocities in [km/s]
	x(13) = 0; % sun x vel init
	x(14) = 0; % sun y vel init
	x(15) = -47.4;  % mercury x vel init (mean)
	x(16) = 0;  % mercury y vel init
	x(17) = -35.0;  % venus x vel init (mean)
	x(18) = 0;  % venus y vel init
	x(19) = -29.8;  % earth x vel init (mean)
	x(20) = 0;  % earth y vel init
	x(21) = 24.1;  % mars x vel init
	x(22) = 0;  % mars y vel init
	x(23) = -29.8;  % rocket x init
	x(24) = 0;  % rocket y init

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
	N = 110*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)
	%numFrameSkip = 2; % number for frames to skip for animation

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

	x(7) = 100*0.35; % star 1 x vel init
	x(8) = 100*0.54; % star 1 y vel init
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
	deltaT = 0.01; % step size 
	N = T*2/deltaT;  % period * num iterations to display / step size
	%numFrameSkip = 1; % number for frames to skip for animation

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
	N = 365*7*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)
	%numFrameSkip = 5;		% only capture every numFrameSkip'th frame, animation code takes awhile

	numbodies = 5;  % number of solar systems
	n = 5*numbodies;  % number of bodies
	m = zeros(1,n);  % masses in [kg]
	x = zeros(1,4*n);  % state space variables
	
	m(1) = 1.9885e30;  % sun
	m(2) = 3.302e23;  % mercury
	m(3) = 4.869e24;  % venus
	m(4) = 5.974e24;  % earth 
	m(5) = 6.419e23;  % mars

	m(6:10) = m(1:5);
	m(11:15) = m(1:5);
	m(16:20) = m(1:5);
	m(21:25) = m(1:5);

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

	posoff = 1.5e9;
	x(11:20) = x(1:10) + posoff;
	x(21:2:29) = x(1:2:9) - posoff;
	x(22:2:30) = x(2:2:10) + posoff;
	x(31:2:39) = x(1:2:9) - posoff;
	x(32:2:40) = x(2:2:10) - posoff;
	x(41:2:49) = x(1:2:9) + posoff;
	x(42:2:50) = x(2:2:10) - posoff;

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
	x(2*n+31:2:2*n+39) = x(2*n+1:2:2*n+9) + veloff;
	x(2*n+32:2:2*n+40) = x(2*n+2:2:2*n+10) + veloff;
	x(2*n+41:2:2*n+49) = x(2*n+1:2:2*n+9) - veloff;
	x(2*n+42:2:2*n+50) = x(2*n+2:2:2*n+10) + veloff;
elseif ic==7 % this scenario includes other body with a blackhold
 %http://hyperphysics.phy-astr.gsu.edu/hbase/Solar/soldata2.html
% positions in [km]

deltaT = 1*3600; % step size (hr * s/hr) [s]
N = 100*2*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)

n = 7;  % number of bodies
m = zeros(1,n);  % masses in [kg]
m(1) = 1.9885e30;  % sun
m(2) = 3.302e23;  % mercury
m(3) = 4.869e24;  % venus
m(4) = 5.974e24;  % earth 
m(5) = 6.419e23;  % mars
m(6)= 3.5e30; % Black hole's mass
m(7)= 3.5e5;  % rocket mass

%http://hyperphysics.phy-astr.gsu.edu/hbase/Solar/soldata2.html
% positions in [km]
x(1) = 0;  % sun x init
x(2) = 0;  % sun y initial
x(3) = 0;  % mercury x init
x(4) = 5.79e7; % mercury y init
x(5) = 0;  % venus x init
x(6) = 1.082e8; % venus y init
x(7) = 0;  % earth x init
x(8) = 1.4960e8;  % earth y init
x(9) = 0;  % mars x init
x(10) = 2.279e8;  % mars y init
x(11) = -2.279e8; % Blackhole x init
x(12) = -2.279e8; % Black hole y init
x(13)= 0; % rocket
x(14)= 1.4960e8;
% velocities in [km/s]
x(15) = 0; % sun x vel init
x(16) = 0; % sun y vel init
x(17) = -47.4;  % mercury x vel init (mean)
x(18) = 0;  % mercury y vel init
x(19) = -35.0;  % venus x vel init (mean)
x(20) = 0;  % venus y vel init
x(21) = -29.8;  % earth x vel init (mean)
x(22) = 0;  % earth y vel init
x(23) = -24.1;  % mars x vel init
x(24) = 0;  % mars y vel init    
x(25)= 0; % Black holes x vel init
x(26)=0; % Black holes y vel init
x(27)=-29.8; % rocket x init vel
x(28)=0; % rocket y init vel

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

	% inject impulsive delta V
	if ic == 2 & i == 8000
		x(23) = x(23) + 2.75;  % add a 3 km/s burn in x dir
		x(24) = x(24) - 3.5;  % add a 3 km/s burn in x dir
    elseif ic==7 && i==1700
        x(27)=x(27)-30;
        x(28)=x(28)+20;
    end
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

ph = zeros(n,1);  % array of plot handles so we can change colors
colorlist = zeros(n,3);  % array of colors given by matlab

% enlarge moon positions so we can see it orbit eart
%xgraph(3,:) = xgraph(3,:) * 1.1;
%ygraph(3,:) = ygraph(3,:) * 1.1;

for i = 1:n
	ph(i) = plot(xgraph(i,:),ygraph(i,:),'.-');
	
	% only get colors for first 5 (sun and 4 planets)
	if i <= 5
		colorlist(i,:) = get(ph(i),'color');
	end
end

if ic == 2 || ic == 6
	for i = 0:numbodies:n-1
		set(ph(1+i),'color',colorlist(3,:));  % sun
		set(ph(2+i),'color',colorlist(4,:));  % mercury
		set(ph(3+i),'color',colorlist(5,:));  % venus
		set(ph(4+i),'color',colorlist(1,:));  % earth
		set(ph(5+i),'color',colorlist(2,:));  % mars
	end

	if ic == 2
		legend('sun','mercury','venus','earth','mars');
	end
end

% change colors on plot
set(gca,'color','black');

% set axis
if ic == 4
	axis([-3.5e7 3.5e7 -3.5e7 3.5e7]);
elseif ic == 5
	axis([-1.5 1.5 -1.5 1.5]);
elseif ic == 6
	axis([-2e9 2e9 -2e9 2e9]);
else
	axis([-2.5e8 2.5e8 -2.5e8 2.5e8]);
end
drawnow;

% ****************************************************************************************
% animation code
% ****************************************************************************************
if makemovie == true
	% open movie file with frame rate calculated above and name from list
	writerObj = VideoWriter(char(movienames(ic)));

	%frate = N/(runtime*numFrameSkip);  % frame rate
	writerObj.FrameRate = frate;
	open(writerObj);

	% setup plot
	figure;
	hold on;

	if ic == 4
		axis([-5e7 5e7 -5e7 5e7]);
	elseif ic == 5
		axis([-1.5 1.5 -1.5 1.5]);
	elseif ic == 6
		axis([-2e9 2e9 -2e9 2e9]);
    elseif ic==7
        axis([-3e8 3e8 -3e8 3e8]);
	else
		axis([-2.5e8 2.5e8 -2.5e8 2.5e8]);
	end

	% first plot all the discs and just change their positions later on
	for j = 1:n
		if ic == 6
			ph(j) = plot(xgraph(j,1),ygraph(j,1),'.','markersize',25);
		elseif ic == 2 & mod(j,numbodies) == 1
			ph(j) = plot(xgraph(j,1),ygraph(j,1),'.','markersize',75);
		elseif ic == 2 & j == 6
			ph(j) = plot(xgraph(j,1),ygraph(j,1),'<','markersize',5);
		elseif ic == 4 || ic == 5
			ph(j) = plot(xgraph(j,1),ygraph(j,1),'.','markersize',50);
        elseif ic==7
            
            if j==1; % 
                
         ph(j) =plot(xgraph(j,i),ygraph(j,i),'.','markersize',120,'color',[0.9100    0.4100    0.1700])
         elseif j==4;  % Earth
          ph(j) =plot(xgraph(j,i),ygraph(j,i),'b.','markersize',20)
        elseif j==5; % Mars
         ph(j) =plot(xgraph(j,i),ygraph(j,i),'r.','markersize',40)
        
        elseif j==6;  % Blackhole
          ph(j) =plot(xgraph(j,i),ygraph(j,i),'w.','markersize',70)
        elseif j==7;
         ph(j) =plot(xgraph(j,i),ygraph(j,i),'y^','markersize',2)
        else
		ph(j) =plot(xgraph(j,i),ygraph(j,i),'.','markersize',10)
            end
            
        else
            
			ph(j) = plot(xgraph(j,1),ygraph(j,1),'.','markersize',40);
		end
	end

	if ic == 2 || ic == 6
		for i = 0:numbodies:n-1
			set(ph(1+i),'color',colorlist(3,:));  % sun
			set(ph(2+i),'color',colorlist(4,:));  % mercury
			set(ph(3+i),'color',colorlist(5,:));  % venus
			set(ph(4+i),'color',colorlist(1,:));  % earth
			set(ph(5+i),'color',colorlist(2,:));  % mars
		end
	end

	if ic == 2
		[~, objh] = legend(ph(1:5),'sun','mercury','venus','earth','mars','AutoUpdate','off');
		objhl = findobj(objh, 'type', 'line'); %// objects of legend of type line
		set(objhl, 'Markersize', 25); %// set marker size as desired
    elseif ic == 7
		[~, objh] = legend(ph(1:6),'sun','mercury','venus','earth','mars','Black Hole','AutoUpdate','off');
		objhl = findobj(objh, 'type', 'line'); %// objects of legend of type line
		set(objhl, 'Markersize', 25); %// set marker size as desired
	end
	
	set(gca,'color','black');
	
	% start at 1*numFrameSkip, first point already plotted
	% now plot all the orbit lines following the discs so the orbits are created as the disc moves
	% keep the same colors used above for the first few discs
	numFrameSkip = ceil(N/numframes);  % need to make sure we have correct num frames for frame rate
	for i = numFrameSkip:numFrameSkip:N
		if ic == 6
			for j = 0:numbodies:n-1
				plot(xgraph(1+j,1:numFrameSkip:i),ygraph(1+j,1:numFrameSkip:i),'-','color',colorlist(3,:));
				plot(xgraph(2+j,1:numFrameSkip:i),ygraph(2+j,1:numFrameSkip:i),'-','color',colorlist(4,:));
				plot(xgraph(3+j,1:numFrameSkip:i),ygraph(3+j,1:numFrameSkip:i),'-','color',colorlist(5,:));
				plot(xgraph(4+j,1:numFrameSkip:i),ygraph(4+j,1:numFrameSkip:i),'-','color',colorlist(1,:));
				plot(xgraph(5+j,1:numFrameSkip:i),ygraph(5+j,1:numFrameSkip:i),'-','color',colorlist(2,:));
			end

			for j = 1:n
				set(ph(j),'XData',xgraph(j,i));
				set(ph(j),'YData',ygraph(j,i));
				drawnow;
			end
		elseif ic == 4
			plot(xgraph(1,1:numFrameSkip:i),ygraph(1,1:numFrameSkip:i),'-','color',colorlist(1,:));
			plot(xgraph(2,1:numFrameSkip:i),ygraph(2,1:numFrameSkip:i),'-','color',colorlist(2,:));
			plot(xgraph(3,1:numFrameSkip:i),ygraph(3,1:numFrameSkip:i),'-','color',colorlist(3,:));

			for j = 1:n
				set(ph(j),'XData',xgraph(j,i));
				set(ph(j),'YData',ygraph(j,i));
				drawnow;
            end
		else
			for j = 1:n
				plot(xgraph(j,1:numFrameSkip:i),ygraph(j,1:numFrameSkip:i),'-w');

				set(ph(j),'XData',xgraph(j,i));
				set(ph(j),'YData',ygraph(j,i));
				
				drawnow;
			end
		end

		M = getframe;
		writeVideo(writerObj,M);
		%hold off;
	end

	movie(M);
	close(writerObj);

end  % end animation code

