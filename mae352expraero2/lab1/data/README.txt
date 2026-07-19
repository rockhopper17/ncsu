Column definitions in the provided 'calibration_*.txt' data files: time (s) | P_01 (psi) | P_1 (psi) | P_02 (psi) | Patm (psi) | T_01 (degree F)
Column definitions in 'manufacturer_calibration_curve_supersonic_tunnel.txt': Block Setting | Mach Number

Notes:
- The file names correspond to the block settings at which the data was collected.
- 'manufacturer_calibration_curve_supersonic_tunnel.txt' contains the manufacturers calibration curve.
- All recorded pressures are gauge pressures. Remember to add the atmospheric pressure during your analysis.
- Only consider data beyond 2.5 seconds of run time. This is due to the fact that it takes the flow that amount of time to reach the pre-set freestream stagnation pressure (P_01) of 60 psi.
- Suggestion - In order to get the solution for the Mach number from the Rayleigh Pitot equation, you can use, fsolve(), the in-built Newton-iterator in MATLAB. More information on the implementation of the same can be found on MATLAB's on-line documentation.
- The report needs to be in the AIAA prescribed format.
- All results in your final report need to be in SI units.
- As discussed in the lab, focus on critial analysis. Point out and discuss interesting trends (if any) in the data.
- In order to get the extra credit, you will have to present detailed analysis and plots. 
