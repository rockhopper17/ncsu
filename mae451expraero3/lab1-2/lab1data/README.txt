Column definitions in instrumentation_data_Q_POS/NEGX.dat: Position | Qtransducer (psf) | Qpitot (Pa) | Tacq (deg C) | Twire (deg C) | Tref (deg C) | Eacq (V DC)

Column definitions in voltage_time_history_Q_POSX_position_X.dat: time (seconds) | Eacq (V DC)

Notes:
- Assume density = 1.14 kg/m^3 for your calculations.
- Calculate tunnel velocity using Qpitot. 
- You will need to calculate turbulence intensity at position 2.
- 'POS' files contain data collected as we increase the dynamic pressure setting and 'NEG' files contain data collected as we decrease the dynamic pressure setting.
- The Tacq to correct the voltage time history data while calculating turbulence intensity should be taken from the instrumentation_data_Q_POSX.dat for the particular position.     
- Focus on critial analysis. Point out and discuss interesting trends (if any) in the data.
- The processing code should be an input-output type code. The only input going into your code will be the raw data files provided (as is) and the output needs to be the final plots.
- Provide your data processing codes in the Appendix. Code efficiency will be tested and points will be allocated accordingly.
- Use parallel for-loops ('parfor' command in MATLAB) for processing the voltage history files. Using a normal for-loop will cause MATLAB to crash.

Extra credit:
- You can calculate the average turbulence intensity based on the turbulence values at all positions for extra credit.   
