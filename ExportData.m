% export data from svd so it can be processed on my mac

% clear all vars and plots
close all; clear all; clc;

% files to process, assumes time synced, will append all data points together
% fnames = ["Scan_time.svd"];
% svdmatname = 'svddata.mat';
% fnames = ["Scan_time.svd","Scan_time_plate.svd"];
% svdmatname = 'svddata2.mat';
fnames = ["Scan_time_horn.svd"];
svdmatname = 'svddata_horn.mat';
% fnames = ["Scan_time_rect.svd"];
% svdmatname = 'svddata_rect.mat';

numf = numel(fnames);

% pull out image
imageData = GetVideoImage(fnames(1));

% init data structures to hold position and velocity values
xyz = double.empty(0);
amp_x = double.empty(0);
amp_y = double.empty(0);
amp_z = double.empty(0);

% loop files and process
for fidx = 1:numf
    fname = fnames(fidx)

    xyz_t = GetXYZCoordinates(fname,0);

    [t, amp_x_t, usd_x] = GetPointData(fname, 'Time', 'Vib X', 'Velocity', 'Samples', 0, 0);
    [t, amp_y_t, usd_y] = GetPointData(fname, 'Time', 'Vib Y', 'Velocity', 'Samples', 0, 0);
    [t, amp_z_t, usd_z] = GetPointData(fname, 'Time', 'Vib Z', 'Velocity', 'Samples', 0, 0);
    
    xyz = [xyz; xyz_t];
    amp_x = [amp_x; amp_x_t];
    amp_y = [amp_y; amp_y_t];
    amp_z = [amp_z; amp_z_t];
end

% save desired workspace variables
clear xyz_t amp_x_t amp_y_t amp_z_t fidx fname
save(svdmatname);