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
ndim = ic.ndim

# execute the integration loop and get plot data
t = np.zeros(N)

gd = np.zeros((N,n,ndim))
gdG = np.zeros((N,ndim))

summ = np.sum(m[:])  # sum of all masses for center of gravity calc

for i in range(N):
    ti = i*deltaT
    t[i] = ti
  
    # pull out the positions from first half of x
    for k in range(ndim):
        gd[i,:,k] = x[k:ndim*n:ndim]

    # calculate center of gravity
    for k in range(ndim):
        sumj = 0
        for j in range(n):
            sumj += (m[j] * gd[i,j,k])

        gdG[i,k] = (sumj / summ)

    # using RK4 integrator	
    x = odeorbits.rk4(x, t, deltaT)

# show the plot of orbit paths
if makeplot:
    plt.ion()  # turn on interactive plot mode

    fig = plt.figure(1)
    ax = plt3.Axes3D(fig)
    ax.set_title('Figure 2.3: Motion relative to the inertial frame')

    for i in range(n):
        ax.plot(gd[:,i,0], gd[:,i,1], gd[:,i,2])
    
    ax.plot(gdG[:,0], gdG[:,1], gdG[:,2])

    plt.show()

    fig = plt.figure(2)
    ax = plt3.Axes3D(fig)
    ax.set_title('Figure 2.4a: Motion of m2 and G relative to m1')

    ax.plot(gd[:,1,0] - gd[:,0,0], gd[:,1,1] - gd[:,0,1], gd[:,1,2] - gd[:,0,2])
    ax.plot(gdG[:,0] - gd[:,0,0], gdG[:,1] - gd[:,0,1], gdG[:,2] - gd[:,0,2])

    plt.show()

    fig = plt.figure(3)
    ax = plt3.Axes3D(fig)
    ax.set_title('Figure 2.4b: Motion of m1 and m2 relative to G')

    ax.plot(gd[:,0,0] - gdG[:,0], gd[:,0,1] - gdG[:,1], gd[:,0,2] - gdG[:,2])
    ax.plot(gd[:,1,0] - gdG[:,0], gd[:,1,1] - gdG[:,1], gd[:,1,2] - gdG[:,2])

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

