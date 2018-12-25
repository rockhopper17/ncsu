import numpy as np
import constants

# Runge-Kutta 4th order integration
def rk4(x, t):
    # retrieve constants and set to locals
    deltaT = constants.DELTAT

    # perform the runge-kutta 4th order integration steps
    f1 = orbits_state(x, t)
    f2 = orbits_state(x + (0.5 * deltaT * f1), t + (0.5 * deltaT))
    f3 = orbits_state(x + (0.5 * deltaT * f2), t + (0.5 * deltaT))
    f4 = orbits_state(x + (deltaT * f3), t + (deltaT))

    return x + (deltaT/6) * (f1 + 2*f2 + 2*f3 + f4)

# state equations
def orbits_state(x, t):

    # retrieve constants and set to locals
    G = constants.G
    n = constants.NUMBODIESTOTAL
    m = constants.MASSVALS

    # pull out x and y values into separate arrays
    xvals = x[0:2*n:2]
    yvals = x[1:2*n:2]

    # f holds the state equations, which are dot and double dot values
    # velocity / first derivatives (x dot, y dot] go in the first half of f
    # acceleration / second derivatives are calculated below
    f = np.zeros((4*n))
    f[0:2*n] = x[2*n::]
    
    # distance between bodies and corresponding unit vectors
    # r[i,j] = distance from ith body to jth body
    # ex[i,j] or ey(i,j) = unit vector for x,y dir from ith body to jth body
    # todo: optimize this code to remove repeated calculations and unit vectors
    r = np.zeros((n,n))
    ex = np.zeros((n,n))
    ey = np.zeros((n,n))

    for i in range(n):
        r[i,:] = np.sqrt( (xvals[i] - xvals[:])**2 + (yvals[i] - yvals[:])**2 )
        ex[i,:] = np.nan_to_num( (xvals[:] - xvals[i]) / r[i,:] )
        ey[i,:] = np.nan_to_num( (yvals[:] - yvals[i]) / r[i,:] )

    # acceleration / second derivatives [x double dot, y double dot]
    # derived from Newton: F = G m1 m2 / r^2
    # note: unit vector value of 0 for ith-ith [same body] will take care of
    #       the acceleration value of a body relative to itself
    for i in range(n):
        f[2*n+(2*i)] = np.sum(np.nan_to_num(G * m[:] * ex[i,:] / r[i,:]**2))
        f[2*n+(2*i+1)] = np.sum(np.nan_to_num(G *m[:] * ey[i,:] / r[i,:]**2))

    # energy calculations
    # sum these
    # if you get delta E,
    # total E is constant, not for each object
    # do this before the integration
    #E = zeros[n,n]
    #for i = 1:n
            #E[i,1:end] = -G*m(i).*m./r(i,:)
    #end

    return f

