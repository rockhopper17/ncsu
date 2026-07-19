import numpy as np
import importlib

# Runge-Kutta 4th order integration
def rk4(statemodule,statefunc, x, t, deltaT):
    # dynamically import the module with the state function
    sm = importlib.import_module(statemodule)
    # NOT WORKING with dynamic function name, don't want to get too far into dynamic calls
    # so just copied this into the main file
    
    # perform the runge-kutta 4th order integration steps
    f1 = sm.statefunc(x, t)
    f2 = sm.statefunc(x + (0.5 * deltaT * f1), t + (0.5 * deltaT))
    f3 = sm.statefunc(x + (0.5 * deltaT * f2), t + (0.5 * deltaT))
    f4 = sm.statefunc(x + (deltaT * f3), t + (deltaT))

    return x + (deltaT/6) * (f1 + 2*f2 + 2*f3 + f4)

