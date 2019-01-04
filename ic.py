import numpy as np

# 1 = orig inner planets with rocket
# 2 = ex 2.2
icval = 2

# initial condition swtich; ic value will be set in the main orbits.py file
if icval == 1:
    # initial timing conditions
    deltaT = 1*3600 # step size (hr * s/hr) [s]
    N = 2*365*(24*3600)//deltaT  # num steps days * (hrs/day * s/hr)
    #N = 30*(24*3600)//deltaT  # num steps days * (hrs/day * s/hr)
    runtime = 30  # default num seconds to run each scenario
    #frate = N/(30*numFrameSkip)  # frame rate

    # universal gravitational constant [km^3/kg/s^2]
    G = 6.67259e-20      

    # n and m values repeated in orbits_state function, along with G
    n = 6  # number of bodies total

    m = np.zeros(n)  # masses in [kg]
    m[0] = 1.9885e30  # sun
    m[1] = 3.302e23  # mercury
    m[2] = 4.869e24  # venus
    m[3] = 5.974e24  # earth 
    m[4] = 6.419e23  # mars
    m[5] = 358  # rocket

    #http://hyperphysics.phy-astr.gsu.edu/hbase/Solar/soldata2.html
    # initial positions [x y z] in [km]
    r1 = np.array([0,0,0]) # sun
    r2 = np.array([0,5.79e7,0]) # mercury
    r3 = np.array([0,1.082e8,0]) # venus
    r4 = np.array([0,1.496e8,0]) # earth
    r5 = np.array([0,-2.279e8,0]) # mars
    r6 = np.array([0,1.496e8,0]) # rocket (starts on earth)

    # initial velocities [vx, vy, vz] in [km/s]
    v1 = np.array([0,0,0])
    v2 = np.array([-47.4,0,0])
    v3 = np.array([-35.0,0,0])
    v4 = np.array([-29.8,0,0])
    v5 = np.array([24.1,0,0])
    v6 = np.array([-29.8,0,0])

    # state space array with initial conditions
    # the x vector holds x y z positions of each body and their velocities (derivatives)
    # x[0] = x1, x[1] = y1, x[2] = z1, x[3] = x2, x[4] = y2, x[5] = z2, ...
    # x[3n] = x1 dot, x[3n+1] = y1 dot, x[3n+2] = z1 dot
    x = np.concatenate([r1,r2,r3,r4,r5,r6,v1,v2,v3,v4,v5,v6]);

    # colors for plotting
    pltcolors = np.zeros((n,3))
    pltcolors[0] = [0.9290,0.6940,0.1250] # sun = yellow
    pltcolors[1] = [0.4940,0.1840,0.5560] # mercury = purple
    pltcolors[2] = [0.4660,0.6740,0.1880] # venus = green
    pltcolors[3] = [0.0000,0.4470,0.7410] # earth = blue
    pltcolors[4] = [0.8500,0.3250,0.0980] # mars = red
    pltcolors[5] = [0.3010,0.7450,0.9330] # rocket = light blue

elif icval == 2:
    # initial timing conditions
    runtime = 480  # total time to run sim [s]
    deltaT = 0.025 # step size [s]
    N = int(runtime / deltaT) # total number of iterations to run integration

    # universal gravitational constant [km^3/kg/s^2]
    G = 6.67259e-20      

    # n and m values repeated in orbits_state function, along with G
    n = 2  # number of bodies total

    m = np.zeros(n)  # masses in [kg]
    m[0] = 1e26  # planet 1
    m[1] = 1e26  # planet 2

    #http://hyperphysics.phy-astr.gsu.edu/hbase/Solar/soldata2.html
    # initial positions [x y z] in [km]
    r1 = np.array([0,0,0]) # planet 1
    r2 = np.array([3000,0,0]) # planet 2

    # initial velocities [vx, vy, vz] in [km/s]
    v1 = np.array([10,20,30])
    v2 = np.array([0,40,0])

    # state space array with initial conditions
    # the x vector holds x y z positions of each body and their velocities (derivatives)
    # x[0] = x1, x[1] = y1, x[2] = z1, x[3] = x2, x[4] = y2, x[5] = z2, ...
    # x[3n] = x1 dot, x[3n+1] = y1 dot, x[3n+2] = z1 dot
    x = np.concatenate([r1,r2,v1,v2]);

