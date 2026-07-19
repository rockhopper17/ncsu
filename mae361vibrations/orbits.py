import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import math
import constants
import odeorbits

#*************************************************#
# clear all variables before executing script
# note: need to comment this out when profiling
import IPython
ipython = IPython.get_ipython()
ipython.reset()
#*************************************************#

# retrieve constants and set to locals
deltaT = constants.DELTAT
N = constants.NUMSTEPS
n = constants.NUMBODIESTOTAL
numbodies = constants.NUMBODIESUNIQUE
#m = constants.MASSVALS

runtime = constants.RUNTIME
frate = constants.FRATE
makemovie = True
makeplot = False

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
pltcolors = np.zeros((n,3))
pltcolors[0] = [0.9290,0.6940,0.1250] # sun = yellow
pltcolors[1] = [0.4940,0.1840,0.5560] # mercury = purple
pltcolors[2] = [0.4660,0.6740,0.1880] # venus = green
pltcolors[3] = [0.0000,0.4470,0.7410] # earth = blue
pltcolors[4] = [0.8500,0.3250,0.0980] # mars = red
pltcolors[5] = [0.3010,0.7450,0.9330] # rocket = light blue

# setup plot
fig = plt.figure()
ax = plt.gca()
ax.set_facecolor('black')
plt.title('innersol')
plt.xlabel('x position (km)')
plt.ylabel('y position (km)')
plt.xlim(-2.5e8, 2.5e8)
plt.ylim(-2.5e8, 2.5e8)

# show the plot of orbit paths
if makeplot:
    for i in range(n):
        plt.plot(xgraph[:,i], ygraph[:,i], color = pltcolors[i])

    plt.legend(['sun','mercury','venus','earth','mars'])
    plt.show()

# do the animation
if makemovie:
    #numframes = frate * runtime
    #numFrameSkip = math.ceil(N/numframes) # need to make sure we have correct num frames for frame rate
    numFrameSkip = 20
    frameidx = np.arange(0,N,numFrameSkip)
    numframes = len(frameidx)

    # handles to each orbital body marker on plot
    ph = np.empty(n, dtype=plt.Line2D)

    def init():
        ph[0], = plt.plot(xgraph[0,0], ygraph[0,0], color = pltcolors[0], markersize=50, marker='.')
        ph[1], = plt.plot(xgraph[0,1], ygraph[0,1], color = pltcolors[1], markersize=25, marker='.')
        ph[2], = plt.plot(xgraph[0,2], ygraph[0,2], color = pltcolors[2], markersize=25, marker='.')
        ph[3], = plt.plot(xgraph[0,3], ygraph[0,3], color = pltcolors[3], markersize=25, marker='.')
        ph[4], = plt.plot(xgraph[0,4], ygraph[0,4], color = pltcolors[4], markersize=25, marker='.')
        ph[5], = plt.plot(xgraph[0,5], ygraph[0,5], color = pltcolors[5], markersize=5, marker='<')
    
        return ph,

    def animate(i):
        print(i)
        for j in range(n):
            plt.plot(xgraph[0:i,j],ygraph[0:i,j],'-w')

            ph[j].set_xdata(xgraph[i,j])
            ph[j].set_ydata(ygraph[i,j])

        return ph,

    ani = animation.FuncAnimation(fig, animate, init_func = init, frames = frameidx,
            save_count = numframes, interval = (runtime*1000/numframes), repeat = False)

    ani.save('testpy.mp4')
    #plt.show()


