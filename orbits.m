% main orbit script, calls ode func and makes plots

% clear all vars and plots
close all; clear all; clc;

% call ic.m script to set initial condition variables
ic

% booleans for making plot or movie
makeplot = true;
makemovie = false;

% ****************************************************************************************
% main integration loop
% ****************************************************************************************
t = zeros(1,N);  % time values
gd = zeros(N,n,ndim);  % graph data: time, body, position in x,y,z
d = struct('G',G,'m',m,'n',n,'ndim',ndim);  % data for passing to orbits_state

if icval == 2 || icval == 3
	summ = sum(m);  % sum of all masses for center of gravity calc
	gdG = zeros(N,ndim);  % graph data for center of gravity in x,y,z
elseif icval == 4
	vd = zeros(N,n,ndim);  % velocity data
end

for i = 1:N
	ti = i*deltaT;
    t(i) = ti;
  
    % pull out the positions from first half of x
	for k = 1:ndim
        gd(i,:,k) = x(k:ndim:ndim*n);

		% for ex 2.3 we want the velocities too
		if icval == 4
        	vd(i,:,k) = x(n*ndim+k:ndim:end);
		end
	end

    % calculate center of gravity
	if icval == 2 || icval == 3
		for k = 1:ndim
			sumj = 0;
			for j = 1:n
				sumj = sumj +  m(j) * gd(i,j,k);
			end

			gdG(i,k) = sumj / summ;
		end
	end

    % using RK4 integrator	
    x = rk4(x, t, deltaT, d);

	% inject impulsive delta V for inner sol rocket scenario
	if icval == 1 & i == 8000
		x(23) = x(23) + 2.75;  % add a 3 km/s burn in x dir
		x(24) = x(24) - 3.5;  % add a 3 km/s burn in x dir
	end

end  % end time loop

% ****************************************************************************************
% plots of orbits
% ****************************************************************************************
if makeplot
	if icval == 1
		figure(1)
		title('inner sol with rocket to mars')
		hold on
		grid on

		for i = 1:n
			plot(gd(:,i,1),gd(:,i,2),'.-','color',pltcolors(i,:))
		end
		
		xlabel('x position (km)')
		ylabel('y position (km)')
		legend('sun','mercury','venus','earth','mars')
		axis([-2.5e8 2.5e8 -2.5e8 2.5e8])
		set(gca,'color','black')

	elseif icval == 2
        figure(1)
        title('Figure 2.3: Motion relative to the inertial frame')
		hold on
        plot(gd(:,1,1), gd(:,1,2), '-r')
        plot(gd(:,2,1), gd(:,2,2), '-g')
        plot(gdG(:,1), gdG(:,2), '-b')

        figure(2)
        title('Figure 2.4a: Motion of m2 and G relative to m1')
		hold on
        plot(gd(:,2,1) - gd(:,1,1), gd(:,2,2) - gd(:,1,2), '-g')
        plot(gdG(:,2) - gd(:,1,1), gdG(:,2) - gd(:,1,2), '-b')

        figure(3)
        title('Figure 2.4b: Motion of m1 and m2 relative to G')
		hold on
        plot(gd(:,1,1) - gdG(:,1), gd(:,1,2) - gdG(:,2), '-r')
        plot(gd(:,2,1) - gdG(:,1), gd(:,2,2) - gdG(:,2), '-g')

	elseif icval == 3
        figure(1)
        title('Figure 2.3: Motion relative to the inertial frame')
		hold on
        plot3(gd(:,1,1), gd(:,1,2), gd(:,1,3), '-r')
        plot3(gd(:,2,1), gd(:,2,2), gd(:,2,3), '-g')
		plot3(gdG(:,1), gdG(:,2), gdG(:,3), '-b')

        %comet3(gd(:,1,1), gd(:,1,2), gd(:,1,3))
        %comet3(gd(:,2,1), gd(:,2,2), gd(:,2,3))

		text(gd(1,1,1), gd(1,1,2), gd(1,1,3), '1', 'color', 'r')
		text(gd(1,2,1), gd(1,2,2), gd(1,2,3), '2', 'color', 'g')
		text(gdG(1,1), gdG(1,2), gdG(1,3), 'G', 'color', 'b')
		
		common_axis_settings

		figure(2)
		title('Figure 2.4a: Motion of m2 and G relative to m1')
		hold on
		plot3(gd(:,2,1) - gd(:,1,1), gd(:,2,2) - gd(:,1,2), gd(:,2,3) - gd(:,1,3), '-g')
		plot3(gdG(:,1) - gd(:,1,1), gdG(:,2) - gd(:,1,2), gdG(:,3) - gd(:,1,3), '-b')

		text(gd(1,2,1) - gd(1,1,1), gd(1,2,2) - gd(1,1,2), gd(1,2,3) - gd(1,1,3), '2', 'color', 'g')
		text(gdG(1,1) - gd(1,1,1), gdG(1,2) - gd(1,1,2), gdG(1,3) - gd(1,1,3), 'G', 'color', 'b')

		common_axis_settings

		figure(3)
		title('Figure 2.4b: Motion of m1 and m2 relative to G')
		hold on
		plot3(gd(:,1,1) - gdG(:,1), gd(:,1,2) - gdG(:,2), gd(:,1,3) - gdG(:,3), '-r')
		plot3(gd(:,2,1) - gdG(:,1), gd(:,2,2) - gdG(:,2), gd(:,2,3) - gdG(:,3), '-g')

		text(gd(1,1,1) - gdG(1,1), gd(1,1,2) - gdG(1,2), gd(1,1,3) - gdG(1,3), '1', 'color', 'r')
		text(gd(1,2,1) - gdG(1,1), gd(1,2,2) - gdG(1,2), gd(1,2,3) - gdG(1,3), '2', 'color', 'g')

		common_axis_settings
	elseif icval == 4
		% get radius values for satellite's orbit
		for i = 1:N
			r(i) = norm([gd(i,2,1) gd(i,2,2) gd(i,2,3)]);
		end

		% set earth values used below
		R = 6378; % radius earth [km]
		hours = 3600;

		[rmax imax] = max(r);
		[rmin imin] = min(r);

		v_at_rmax   = norm([vd(imax,2,1) vd(imax,2,2) vd(imax,2,3)]);
		v_at_rmin   = norm([vd(imin,2,1) vd(imin,2,2) vd(imin,2,3)]);

		%...Output to the command window:
		fprintf('\n\n--------------------------------------------------------\n')
		fprintf('\n Earth Orbit\n')
		fprintf(' %s\n', datestr(now))
		fprintf('\n The initial position is [%g, %g, %g] (km).',...
															 r2(1), r2(2), r2(3))
		fprintf('\n   Magnitude = %g km\n', norm(r2))
		fprintf('\n The initial velocity is [%g, %g, %g] (km/s).',...
															 v2(1), v2(2), v2(3))
		fprintf('\n   Magnitude = %g km/s\n', norm(v2))
		fprintf('\n Initial time = %g h.\n Final time   = %g h.\n',0,runtime/hours) 
		fprintf('\n The minimum altitude is %g km at time = %g h.',...
					rmin-R, t(imin)/hours)
		fprintf('\n The speed at that point is %g km/s.\n', v_at_rmin)
		fprintf('\n The maximum altitude is %g km at time = %g h.',...
					rmax-R, t(imax)/hours)
		fprintf('\n The speed at that point is %g km/s\n', v_at_rmax)
		fprintf('\n--------------------------------------------------------\n\n')

		%...Plot the results:
		%   Draw the planet
		[xx, yy, zz] = sphere(100);
		surf(R*xx, R*yy, R*zz)
		colormap(light_gray)
		caxis([-R/100 R/100])
		shading interp

		%   Draw and label the X, Y and Z axes
		line([0 2*R],   [0 0],   [0 0]); text(2*R,   0,   0, 'X')
		line(  [0 0], [0 2*R],   [0 0]); text(  0, 2*R,   0, 'Y')
		line(  [0 0],   [0 0], [0 2*R]); text(  0,   0, 2*R, 'Z')

		%   Plot the orbit, draw a radial to the starting point
		%   and label the starting point (o) and the final point (f)
		hold on
		plot3(  gd(:,2,1),    gd(:,2,2),    gd(:,2,3),'k')
		line([0 r2(1)], [0 r2(2)], [0 r2(3)])
		text(   gd(1,2,1),    gd(1,2,2),    gd(1,2,3), 'o')
		text( gd(end,2,1),  gd(end,2,2),  gd(end,2,3), 'f')

		%   Select a view direction (a vector directed outward from the origin) 
		view([1,1,.4])

		%   Specify some properties of the graph
		grid on
		axis equal
		xlabel('km')
		ylabel('km')
		zlabel('km')


	end  % end icval
end  % end makeplot


% ****************************************************************************************
% animation / movie %
% ****************************************************************************************
if makemovie
	if icval == 1
		% open movie file with frame rate calculated above and name from list
		writerObj = VideoWriter('innersol.avi');

		%frate = N/(runtime*numFrameSkip);  % frame rate
		writerObj.FrameRate = frate;
		open(writerObj);

		% setup plot
		figure
		hold on

		axis([-2.5e8 2.5e8 -2.5e8 2.5e8])

		ph = zeros(n,1);  % array of plot handles so we can change positions
		for j = 1:n
			if j == 1
				% sun
				ph(j) = plot(gd(1,j,1),gd(1,j,2),'.','markersize',75,'color',pltcolors(j,:));
			elseif j == 6
				% rocket
				ph(j) = plot(gd(1,j,1),gd(1,j,2),'<','markersize',5,'color',pltcolors(j,:));
			else
				% planets
				ph(j) = plot(gd(1,j,1),gd(1,j,2),'.','markersize',40,'color',pltcolors(j,:));
			end
		end

		% create legend one time, otherwise it will keep updating on each call to plot
		[~, objh] = legend(ph(1:5),'sun','mercury','venus','earth','mars','AutoUpdate','off');
		objhl = findobj(objh, 'type', 'line'); %// objects of legend of type line
		set(objhl, 'Markersize', 25); %// set marker size as desired

		set(gca,'color','black');

		% start at 1*numFrameSkip, first point already plotted
		% now plot all the orbit lines following the discs so the orbits are created as the disc moves
		% keep the same colors used above for the first few discs
		numFrameSkip = ceil(N/numframes);  % need to make sure we have correct num frames for frame rate
		for i = numFrameSkip:numFrameSkip:N
			for j = 1:n
				plot(gd(1:numFrameSkip:i,j,1),gd(1:numFrameSkip:i,j,2),'-w')

				set(ph(j),'XData',gd(i,j,1));  % update positions
				set(ph(j),'YData',gd(i,j,2));
				
				drawnow
			end

			writeVideo(writerObj,getframe);
		end  % end i (time loop)
	
		close(writerObj);

	end  % end icval == 1
end  % end makemovie

% ****************************************************************************************
%  functions %
% ****************************************************************************************

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
function common_axis_settings
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
  This function establishes axis properties common to the several plots
%}
% ---------------------------
text(0, 0, 0, 'o')
axis('equal')
view([2,4,1.2])
grid on
axis equal
xlabel('X (km)')
ylabel('Y (km)')
zlabel('Z (km)')
end %common_axis_settings

% ~~~~~~~~~~~~~~~~~~~~~~~
function map = light_gray
% ~~~~~~~~~~~~~~~~~~~~~~~
%{
  This function creates a color map for displaying the planet as light
  gray with a black equator.
  
  r - fraction of red
  g - fraction of green
  b - fraction of blue

%}
% -----------------------
r = 0.8; g = r; b = r;
map = [r g b
       0 0 0
       r g b];
end %light_gray


