% export data from svd so it can be processed on my mac

% clear all vars and plots
close all; clear all; clc;

fname = 'Scan_time.svd'

xyz = GetXYZCoordinates(fname,0);

[t, amp_x, usd_x] = GetPointData(fname, 'Time', 'Vib X', 'Velocity', 'Samples', 0, 0);
[t, amp_y, usd_y] = GetPointData(fname, 'Time', 'Vib Y', 'Velocity', 'Samples', 0, 0);
[t, amp_z, usd_z] = GetPointData(fname, 'Time', 'Vib Z', 'Velocity', 'Samples', 0, 0);

% save all workspace variables
save('svddata.mat');