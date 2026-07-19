% initial conditions, to be executed at top of orbits file
% 1 = orig inner planets with rocket from mae361
% 2 = ex 2.2 2D
% 3 = ex 2.2 3D
% 4 = ex 2.3 3D
icval = 3

% initial condition swtich; ic value will be set in the main orbits.py file
if icval == 1
    % initial timing conditions
    deltaT = 1*3600; % step size (hr * s/hr) (s)
    N = 2*365*(24*3600)/deltaT;  % num steps days * (hrs/day * s/hr)
    runtime = 30;  % default num seconds to run each scenario
    %frate = N/(30*numFrameSkip)  # frame rate
	frate = 60;  % frame rate for movie file, hard coded so all match when concatenating
	numframes = frate * runtime;  % total number of frames to capture

    G = 6.67259e-20; % universal gravitational constant (km^3/kg/s^2) 
    n = 6;  % number of bodies total
    ndim = 2; % num dimensions (2D: x,y)

    m = zeros(1,n);  % masses in (kg)
    m(1) = 1.9885e30;  % sun
    m(2) = 3.302e23;  % mercury
    m(3) = 4.869e24;  % venus
    m(4) = 5.974e24;  % earth 
    m(5) = 6.419e23;  % mars
    m(6) = 358;  % rocket

    %http://hyperphysics.phy-astr.gsu.edu/hbase/Solar/soldata2.html
    % initial positions (x y z) in (km)
    r1 = [0,0]; % sun
    r2 = [0,5.79e7]; % mercury
    r3 = [0,1.082e8]; % venus
    r4 = [0,1.496e8]; % earth
    r5 = [0,-2.279e8]; % mars
    r6 = [0,1.496e8]; % rocket (starts on earth)

    % initial velocities (vx, vy, vz) in (km/s)
    v1 = [0,0];
    v2 = [-47.4,0];
    v3 = [-35.0,0];
    v4 = [-29.8,0];
    v5 = [24.1,0];
    v6 = [-29.8,0];

    % state space array with initial conditions
    % the x vector holds x y z positions of each body and their velocities (derivatives)
    % x(1) = x1, x(2) = y1, x(3) = z1, x(4) = x2, x(5) = y2, x(6) = z2, ...
    % x(3n+1) = x1 dot, x(3n+2) = y1 dot, x(3n+3) = z1 dot
    x = [r1,r2,r3,r4,r5,r6,v1,v2,v3,v4,v5,v6];

    % colors for plotting
    pltcolors = zeros(n,3);
    pltcolors(1,:) = [0.9290,0.6940,0.1250]; % sun = yellow
    pltcolors(2,:) = [0.4940,0.1840,0.5560]; % mercury = purple
    pltcolors(3,:) = [0.4660,0.6740,0.1880]; % venus = green
    pltcolors(4,:) = [0.0000,0.4470,0.7410]; % earth = blue
    pltcolors(5,:) = [0.8500,0.3250,0.0980]; % mars = red
    pltcolors(6,:) = [0.3010,0.7450,0.9330]; % rocket = light blue

elseif icval == 2
    % ex 2.2 but in 2D

    % initial timing conditions
    runtime = 480;  % total time to run sim (s)
    deltaT = 0.025; % step size (s)
    N = runtime / deltaT; % total number of iterations to run integration

    G = 6.67259e-20; % universal gravitational constant (km^3/kg/s^2) 
    n = 2;  % number of bodies total
    ndim = 2; % num dimensions (2D: x,y)

    m = zeros(1,n);  % masses in (kg)
    m(1) = 1e26;  % planet 1
    m(2) = 1e26;  % planet 2

    %http://hyperphysics.phy-astr.gsu.edu/hbase/Solar/soldata2.html
    % initial positions (x y z) in (km)
    r1 = [0,0]; % planet 1
    r2 = [3000,0]; % planet 2

    % initial velocities (vx, vy, vz) in (km/s)
    v1 = [10,20];
    v2 = [0,40];

    % state space array with initial conditions
    % the x vector holds x y z positions of each body and their velocities (derivatives)
    % x(0) = x2, x(1) = y1, x(2) = z1, x(3) = x2, x(4) = y2, x(5) = z2, ...
    % x(3n) = x1 dot, x(3n+1) = y1 dot, x(3n+2) = z1 dot
    x = [r1,r2,v1,v2];

elseif icval == 3
    % ex 2.2 in full 3D
	% bookmatlabcode/twobody3d.m

    % initial timing conditions
    runtime = 480;  % total time to run sim (s)
    deltaT = 0.025; % step size (s)
    N = runtime / deltaT; % total number of iterations to run integration

    G = 6.67259e-20; % universal gravitational constant (km^3/kg/s^2) 
    n = 2;  % number of bodies total
    ndim = 3; % num dimensions (3D: x,y,z)

    m = zeros(1,n);  % masses in (kg)
    m(1) = 1e26;  % planet 1
    m(2) = 1e26;  % planet 2

    %http://hyperphysics.phy-astr.gsu.edu/hbase/Solar/soldata2.html
    % initial positions (x y z) in (km)
    r1 = [0,0,0]; % planet 1
    r2 = [3000,0,0]; % planet 2

    % initial velocities (vx, vy, vz) in (km/s)
    v1 = [10,20,30];
    v2 = [0,40,0];

    % state space array with initial conditions
    % the x vector holds x y z positions of each body and their velocities (derivatives)
    % x(0) = x2, x(1) = y1, x(2) = z1, x(3) = x2, x(4) = y2, x(5) = z2, ...
    % x(3n) = x1 dot, x(3n+1) = y1 dot, x(3n+2) = z1 dot
    x = [r1,r2,v1,v2];

elseif icval == 4
    % ex 2.3 in full 3D
	% bookmatlabcode/orbit.m
	% still doing this n-body algorithm, could look at doing 2 body with mu and r^3

    % initial timing conditions
    runtime = 4*3600;  % total time to run sim (hrs * sec/hr = sec)
    deltaT = 60; % step size (s)
    N = runtime / deltaT; % total number of iterations to run integration

    G = 6.67259e-20; % universal gravitational constant (km^3/kg/s^2) 
    n = 2;  % number of bodies total
    ndim = 3; % num dimensions (3D: x,y,z)
	
	% masses [kg]
    m = zeros(1,n); 
    m(1) = 5.974e24;  % earth
    m(2) = 1000;  % satellite

    % initial positions (x y z) [km]
    r1 = [0 0 0];
    r2 = [8000 0 6000];

    % initial velocities (vx, vy, vz) [km/s]
    v1 = [0 0 0];
    v2 = [0 7 0];

    % state space array with initial conditions
    % the x vector holds x y z positions of each body and their velocities (derivatives)
    % x(0) = x2, x(1) = y1, x(2) = z1, x(3) = x2, x(4) = y2, x(5) = z2, ...
    % x(3n) = x1 dot, x(3n+1) = y1 dot, x(3n+2) = z1 dot
    x = [r1,r2,v1,v2];
end

