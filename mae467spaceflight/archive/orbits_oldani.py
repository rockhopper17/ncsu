import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import mpl_toolkits.mplot3d as plt3
import math

import ic
import odeorbits

# clear all variables before executing script
# note: need to comment this out when profiling
import IPython
ipython = IPython.get_ipython()
ipython.reset()

makeplot = False
makemovie = True

# get initial conditions from ic.py script
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

for i in range(N):
    t = i*deltaT
    timevals[i] = t
    
    xgraph[i,:] = x[0:3*n:3]
    ygraph[i,:] = x[1:3*n:3]
    zgraph[i,:] = x[2:3*n:3]

    # using RK4 integrator	
    x = odeorbits.rk4(x, t, deltaT)

    # inject impulsive delta V to rocket (last body in state array)
    if icval == 1 and i == 8000:
        x[6*n-3] += 2.75  # add a 3 km/s burn in x dir to rocket
        x[6*n-2] -= 3.5  # add a 3 km/s burn in x dir to rocket

# plot
if icval == 1:
    pltcolors = np.zeros((n,3))
    pltcolors[0] = [0.9290,0.6940,0.1250] # sun = yellow
    pltcolors[1] = [0.4940,0.1840,0.5560] # mercury = purple
    pltcolors[2] = [0.4660,0.6740,0.1880] # venus = green
    pltcolors[3] = [0.0000,0.4470,0.7410] # earth = blue
    pltcolors[4] = [0.8500,0.3250,0.0980] # mars = red
    pltcolors[5] = [0.3010,0.7450,0.9330] # rocket = light blue

# show the plot of orbit paths
if makeplot:
    fig = plt.figure()
    ax = fig.gca(projection='3d')
    #ax = fig.gca()
    #plt.title('innersol')
    ax.set_xlabel('x position (km)')
    ax.set_ylabel('y position (km)')
    ax.set_zlabel('z position (km)')
    #ax.set_xlim(-2.5e8, 2.5e8)
    #ax.set_ylim(-2.5e8, 2.5e8)
    #ax.set_zlim(-2.5e8, 2.5e8)
    #ax.set_zlim(-1, 1)

    for i in range(n):
        if icval == 1:
            ax.plot(xgraph[:,i], ygraph[:,i], zgraph[:,i], color = pltcolors[i])
        else:
            ax.plot(xgraph[:,i], ygraph[:,i], zgraph[:,i])
        #ax.plot(xgraph[:,i], ygraph[:,i], color = pltcolors[i])

    if icval == 1:
        ax.set_facecolor('black')
        ax.legend(['sun','mercury','venus','earth','mars'])

    plt.show()

# do the animation
if makemovie:
    fig = plt.figure()
    ax = plt3.Axes3D(fig)
    #ax = fig.gca(projection='3d')
    #ax.set_facecolor('black')
    #plt.title('innersol')
    ax.set_xlabel('x position (km)')
    ax.set_ylabel('y position (km)')
    ax.set_zlabel('z position (km)')
    #plt.xlim(-2.5e8, 2.5e8)
    #plt.ylim(-2.5e8, 2.5e8)
    #plt.zlim(-1, 1)
    #numframes = frate * runtime
    #numFrameSkip = math.ceil(N/numframes) # need to make sure we have correct num frames for frame rate
    numFrameSkip = 20
    frameidx = np.arange(0,N,numFrameSkip)
    numframes = len(frameidx)

    # handles to each orbital body marker on plot
    #ph = np.empty(n, dtype=plt3.art3d.Line3D)
    
    ph = [ax.plot([xgraph[0,j]], [ygraph[0,j]], zgraph[0,j], markersize=20, marker='.')[0] for j in range(n)]
    
    #for j in range(n):
        ## note: 3d plot expects iterables for x,y so they are inside []
        #ph[j] = ax.plot([xgraph[0,j]], [ygraph[0,j]], zgraph[0,j], markersize=20, marker='.')

    #def init():
        #if icval == 1:
            #ph[0], = plt.plot(xgraph[0,0], ygraph[0,0], color = pltcolors[0], markersize=50, marker='.')
            #ph[1], = plt.plot(xgraph[0,1], ygraph[0,1], color = pltcolors[1], markersize=25, marker='.')
            #ph[2], = plt.plot(xgraph[0,2], ygraph[0,2], color = pltcolors[2], markersize=25, marker='.')
            #ph[3], = plt.plot(xgraph[0,3], ygraph[0,3], color = pltcolors[3], markersize=25, marker='.')
            #ph[4], = plt.plot(xgraph[0,4], ygraph[0,4], color = pltcolors[4], markersize=25, marker='.')
            #ph[5], = plt.plot(xgraph[0,5], ygraph[0,5], color = pltcolors[5], markersize=5, marker='<')
        #else:
            #for j in range(n):
                #ph[j] = ax.plot(xgraph[0,j], ygraph[0,j], zgraph[0,j], markersize=20, marker='.')
    
        #return ph,

    def animate(i):
        print(i)
        for j in range(n):
            #plt.plot(xgraph[0:i,j],ygraph[0:i,j],'-w')
            ax.plot(xgraph[0:i,j], ygraph[0:i,j], zgraph[0:i,j], '-k')

            # note: there is no .set_data() for 3 dim data
            ph[j].set_data(xgraph[i,j], ygraph[i,j])
            ph[j].set_3d_properties(zgraph[i,j])

        return ph,

    #ani = animation.FuncAnimation(fig, animate, init_func = init, frames = frameidx,
    ani = animation.FuncAnimation(fig, animate, frames = frameidx,
            save_count = numframes, interval = (30*1000/numframes), repeat = False)

    ani.save('testpy.mp4')
    #plt.show()

