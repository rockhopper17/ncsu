% main orbit script, calls ode func and makes plots

% clear all vars and plots
close all; clear all; clc;

% call ic.m script to set initial condition variables
ic

% booleans for making plot or movie
makeplot = true;
makemovie = false;

% execute the integration loop and get plot data
t = zeros(1,N);  % time values
gd = zeros(N,n,ndim);  % graph data: time, body, position in x,y,z
gdG = zeros(N,ndim);  % graph data for center of gravity in x,y,z
summ = sum(m);  % sum of all masses for center of gravity calc
d = struct('G',G,'m',m,'n',n,'ndim',ndim);  % data for passing to orbits_state

for i = 1:N
	ti = i*deltaT;
    t(i) = ti;
  
    % pull out the positions from first half of x
    % calculate center of gravity
	for k = 1:ndim
        gd(i,:,k) = x(k:ndim:ndim*n);
        %gdG(i,k) = sum(m .* gd(i,:,k)) / summ;
	end

    % calculate center of gravity
	for k = 1:ndim
		sumj = 0;
		for j = 1:n
			sumj = sumj +  m(j) * gd(i,j,k);
		end

		gdG(i,k) = sumj / summ;
	end

    % using RK4 integrator	
    x = rk4(x, t, deltaT, d);
end  % end time loop

% show the plot of orbit paths
if makeplot
	if icval == 2
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

        comet3(gd(:,1,1), gd(:,1,2), gd(:,1,3))
        comet3(gd(:,2,1), gd(:,2,2), gd(:,2,3))

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

	end  % end icval
end  % end makeplot

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


% animation / movie

