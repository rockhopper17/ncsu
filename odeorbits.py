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

    # pull out x y z values into separate arrays
    xvals = x[0:3*n:3]
    yvals = x[1:3*n:3]
    zvals = x[2:3*n:3]

    # f holds the state equations, which are dot and double dot values
    # velocity / first derivatives (x dot, y dot, z dot] go in the first half of f
    # acceleration / second derivatives are calculated below
    f = np.zeros((6*n))
    f[0:3*n] = x[3*n::]
    
    # distance between bodies and corresponding unit vectors
    # r[i,j] = distance from ith body to jth body
    # ex[i,j] or ey(i,j) = unit vector for x,y dir from ith body to jth body
    r = np.zeros((n,n))
    ex = np.zeros((n,n))
    ey = np.zeros((n,n))
    ez = np.zeros((n,n))

    for i in range(n):
        for j in range(n):
            # if i == j we are on the same body, so just keep the 0 value alredy in there
            if i != j:
                r[i,j] = np.sqrt( (xvals[i] - xvals[j])**2 + (yvals[i] - yvals[j])**2 + (zvals[i] - zvals[j])**2)
                # could still have distance = 0, for example rocket following earth for awhile
                if r[i,j] != 0:
                    ex[i,j] = (xvals[j] - xvals[i]) / r[i,j]
                    ey[i,j] = (yvals[j] - yvals[i]) / r[i,j]
                    ez[i,j] = (zvals[j] - zvals[i]) / r[i,j]

    # acceleration / second derivatives [x double dot, y double dot]
    # derived from Newton: F = m1 a1 = G m1 m2 / r^2 => a1 = G m2 / r^2
    for i in range(n):
        sumx = 0
        sumy = 0
        sumz = 0
        for j in range(n):
            if i != j and r[i,j] != 0:
                sumx += (G * m[j] * ex[i,j] / r[i,j]**2)
                sumy += (G * m[j] * ey[i,j] / r[i,j]**2)
                sumz += (G * m[j] * ez[i,j] / r[i,j]**2)

        f[3*n+(3*i)] = sumx
        f[3*n+(3*i+1)] = sumy
        f[3*n+(3*i+2)] = sumz

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

