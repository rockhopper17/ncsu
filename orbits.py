import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import mpl_toolkits.mplot3d as plt3
import math

import ic
import odeorbits

#*****************************************************************************#
# clear all variables before executing script
# note: need to comment this out when profiling
import IPython
ipython = IPython.get_ipython()
ipython.reset()
#*****************************************************************************#

# booleans for making plot or movie
makeplot = True
makemovie = False

# get initial conditions from ic.py script
# ic value is chosen/set in ic.py
icval = ic.icval
deltaT = ic.deltaT
N = ic.N
runtime = ic.runtime
G = ic.G
m = ic.m
n = ic.n
x = ic.x

# execute the integration loop and get plot data
timevals = np.zeros(N)

xgraph = np.zeros((N,n))
ygraph = np.zeros((N,n))
zgraph = np.zeros((N,n))
xgraphG = np.zeros(N)
ygraphG = np.zeros(N)
zgraphG = np.zeros(N)

summ = np.sum(m[:])  # sum of all masses for center of gravity calc

for i in range(N):
    t = i*deltaT
    timevals[i] = t
    
    xgraph[i,:] = x[0:3*n:3]
    ygraph[i,:] = x[1:3*n:3]
    zgraph[i,:] = x[2:3*n:3]

    # calculate center of gravity
    sumx = sumy = sumz = 0

    for j in range(n):
        sumx += (m[j] * xgraph[i,j])
        sumy += (m[j] * ygraph[i,j])
        sumz += (m[j] * zgraph[i,j])

    xgraphG[i] = (sumx / summ)
    ygraphG[i] = (sumy / summ)
    zgraphG[i] = (sumz / summ)

    # using RK4 integrator	
    x = odeorbits.rk4(x, t, deltaT)

# show the plot of orbit paths
if makeplot:
    plt.ion()  # turn on interactive plot mode

    fig = plt.figure(1)
    ax = plt3.Axes3D(fig)
    ax.set_title('Figure 2.3: Motion relative to the inertial frame')

    for i in range(n):
        ax.plot(xgraph[:,i], ygraph[:,i], zgraph[:,i])
    
    ax.plot(xgraphG[:], ygraphG[:], zgraphG[:])

    plt.show()

    fig = plt.figure(2)
    ax = plt3.Axes3D(fig)
    ax.set_title('Figure 2.4a: Motion of m2 and G relative to m1')

    ax.plot(xgraph[:,1] - xgraph[:,0], ygraph[:,1] - ygraph[:,0], zgraph[:,1] - zgraph[:,0])
    ax.plot(xgraphG[:] - xgraph[:,0], ygraphG[:] - ygraph[:,0], zgraphG[:] - zgraph[:,0])

    plt.show()

    fig = plt.figure(3)
    ax = plt3.Axes3D(fig)
    ax.set_title('Figure 2.4b: Motion of m1 and m2 relative to G')

    ax.plot(xgraph[:,0] - xgraphG[:], ygraph[:,0] - ygraphG[:], zgraph[:,0] - zgraphG[:])
    ax.plot(xgraph[:,1] - xgraphG[:], ygraph[:,1] - ygraphG[:], zgraph[:,1] - zgraphG[:])

    plt.show()


# do the animation
if makemovie:
    fig = plt.figure()
    ax = plt3.Axes3D(fig)
    ax.set_xlabel('x position (km)')
    ax.set_ylabel('y position (km)')
    ax.set_zlabel('z position (km)')
    numFrameSkip = 20
    frameidx = np.arange(0,N,numFrameSkip)
    numframes = len(frameidx)

    # handles to each orbital body marker on plot
    ph = [ax.plot([xgraph[0,j]], [ygraph[0,j]], zgraph[0,j], markersize=20, marker='.')[0] for j in range(n)]
    
    def animate(i):
        print(i)
        for j in range(n):
            #plt.plot(xgraph[0:i,j],ygraph[0:i,j],'-w')
            ax.plot(xgraph[0:i,j], ygraph[0:i,j], zgraph[0:i,j], '-k')

            # note: there is no .set_data() for 3 dim data
            ph[j].set_data(xgraph[i,j], ygraph[i,j])
            ph[j].set_3d_properties(zgraph[i,j])

        return ph,

    ani = animation.FuncAnimation(fig, animate, frames = frameidx,
            save_count = numframes, interval = (30*1000/numframes), repeat = False)

    ani.save('testpy.mp4')
    #plt.show()

