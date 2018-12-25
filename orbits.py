import numpy as np
#import matplotlib.pyplot as plt
import constants
import odeorbits

# clear all variables before executing script
#import IPython
#ipython = IPython.get_ipython()
#ipython.reset()

# retrieve constants and set to locals
deltaT = constants.DELTAT
N = constants.NUMSTEPS
n = constants.NUMBODIESTOTAL
numbodies = constants.NUMBODIESUNIQUE
#m = constants.MASSVALS

runtime = constants.RUNTIME
frate = constants.FRATE
numframes = constants.NUMFRAMES

# state space array with initial conditions
# the x vector holds x, y positions of each body and their velocities (derivatives)
# x(1) = x1, x(2) = y1, x(3) = x2, x(4) = y2, ...
# x(2n+1) = x1 dot, x(2n+2) = y1 dot, x(2n+3) = x2 dot, x(2n+4) = y2 dot, ...
x = np.zeros(4*n)  # state space variables

#http://hyperphysics.phy-astr.gsu.edu/hbase/Solar/soldata2.html
# positions in [km]
x[0] = 0  # sun x init
x[1] = 0  # sun y init
x[2] = 0  # mercury x init
x[3] = 5.79e7 # mercury y init
x[4] = 0  # venus x init
x[5] = 1.082e8 # venus y init
x[6] = 0  # earth x init
x[7] = 1.4960e8  # earth y init
x[8] = 0  # mars x init
x[9] = -2.279e8  # mars y init
x[10] = 0  # rocket x init [on earth]
x[11] = 1.4960e8  # rocket y init [on earth]

# velocities in [km/s]
x[12] = 0 # sun x vel init
x[13] = 0 # sun y vel init
x[14] = -47.4  # mercury x vel init [mean]
x[15] = 0  # mercury y vel init
x[16] = -35.0  # venus x vel init [mean]
x[17] = 0  # venus y vel init
x[18] = -29.8  # earth x vel init [mean]
x[19] = 0  # earth y vel init
x[20] = 24.1  # mars x vel init
x[21] = 0  # mars y vel init
x[22] = -29.8  # rocket x init
x[23] = 0  # rocket y init

# execute the integration loop and get plot data
timevals = np.zeros(N)
xgraph = np.zeros((N,n))
ygraph = np.zeros((N,n))

for i in range(N):
    t = i*deltaT
    timevals[i] = t
    
    xgraph[i,:] = x[0:2*n:2]
    ygraph[i,:] = x[1:2*n:2]

    # using RK4 integrator	
    x = odeorbits.rk4(x,t)

    # inject impulsive delta V
    if i == 8000:
        x[22] += 2.75  # add a 3 km/s burn in x dir
        x[23] -= 3.5  # add a 3 km/s burn in x dir

# plot
#for i in range(n):
    #plt.plot(xgraph[:,i], ygraph[:,i])
   
#plt.show()

