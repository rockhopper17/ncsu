import numpy as np

import ic

# Runge-Kutta 4th order integration
def rk4(x, t, deltaT):
    # perform the runge-kutta 4th order integration steps
    f1 = orbits_state(x, t)
    f2 = orbits_state(x + (0.5 * deltaT * f1), t + (0.5 * deltaT))
    f3 = orbits_state(x + (0.5 * deltaT * f2), t + (0.5 * deltaT))
    f4 = orbits_state(x + (deltaT * f3), t + (deltaT))

    return x + (deltaT/6) * (f1 + 2*f2 + 2*f3 + f4)

# state equations
def orbits_state(x, t):
    # get initial conditions from ic.py script
    G = ic.G
    m = ic.m
    n = ic.n
    ndim = ic.ndim

    # f holds the state equations, which are dot and double dot values
    # velocity / first derivatives (x dot, y dot, z dot] go in the first half of f
    # acceleration / second derivatives are calculated below
    f = np.zeros((x.size))
    f[0:ndim*n] = x[ndim*n::]
    
    # distance between bodies and corresponding unit vectors
    # r[i,j] = distance from ith body to jth body
    # e[i,j,dim] = unit vector in dim (x,y,z) for dir from ith body to jth body
    r = np.zeros((n,n))
    e = np.zeros((n,n,ndim))

    for i in range(n):
        for j in range(n):
            # if i == j we are on the same body, so just keep the 0 value alredy in there
            if i != j:
                sumk = 0
                for k in range(ndim):
                    sumk += (x[i*ndim+k] - x[j*ndim+k])**2
                r[i,j] = np.sqrt(sumk)

                # could still have distance = 0, for example rocket following earth for awhile
                if r[i,j] != 0:
                    for k in range(ndim):
                        e[i,j,k] = (x[j*ndim+k] - x[i*ndim+k]) / r[i,j]

    # acceleration / second derivatives [x double dot, y double dot]
    # derived from Newton: F = m1 a1 = G m1 m2 / r^2 => a1 = G m2 / r^2
    for i in range(n):
        for k in range(ndim):
            sumj = 0
            for j in range(n):
                if i != j and r[i,j] != 0:
                    sumj += (G * m[j] * e[i,j,k] / r[i,j]**2)

            f[ndim*n+(ndim*i+k)] = sumj

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

