import numpy as np

# universal gravitational constant [km^3/kg/s^2]
G = 6.67259e-20      

# default step size values, sometimes modified in the ic scenariois
DELTAT = 1*3600 # step size (hr * s/hr) [s]
NUMSTEPS = 2*365*(24*3600)//DELTAT  # num steps days * (hrs/day * s/hr)
#NUMSTEPS = 30*(24*3600)//DELTAT  # num steps days * (hrs/day * s/hr)

# only capture every numFrameSkip'th frame, animation code takes awhile
#numFrameSkip = 25  # default number of frames to skip
#numFrameSkipMult = 1  # default multiplier on number of frames to skip
# base the frame rate on the inner sol and calculate others to match this
# 30 seconds for each scenario
RUNTIME = 30  # default num seconds to run each scenario
#frate = N/(30*numFrameSkip)  # frame rate
FRATE = 60  # frame rate for movie file, hard coded so all match when concatenating

NUMBODIESTOTAL = 6  # number of bodies total
NUMBODIESUNIQUE = 6  # num unique bodies

MASSVALS = np.zeros(NUMBODIESTOTAL)  # masses in [kg]
MASSVALS[0] = 1.9885e30  # sun
MASSVALS[1] = 3.302e23  # mercury
MASSVALS[2] = 4.869e24  # venus
MASSVALS[3] = 5.974e24  # earth 
MASSVALS[4] = 6.419e23  # mars
MASSVALS[5] = 358  # mars

