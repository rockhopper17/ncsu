% MAE 352 PSP Experiment
% Pranav Hosangadi | phosang@ncsu.edu
% 01 Apr 2019
function [ a2, c, h ] = psp_plotcontour( ax, x, y, pvals, levels )
%PSP_PLOTCONTOUR Overlays the contour of pressures measured using PSP over 
% an existing axis containing the image obtained from the camera.
%   Inputs: 
%       ax: The axis on which to overlay the contour ( Usually gca )
%       x: x locations, passed to contourf argument "X" (MxN array)
%       y: y locations, passed to contourf argument "Y" (MxN array)
%       pvals: Pressure values, passed to contourf argument "Z" (MxN array)
%       levels: levels for contourf, passed to contourf argument "levels"
%   See help contourf for more info about the contourf arguments

if nargin == 4
    levels = 100;
end

a2 = axes('position', ax.Position);
[c, h] = contourf(x, y, pvals, levels, 'linecolor', 'none');

set(a2, 'XLim', ax.XLim, 'YLim', ax.YLim, 'XDir', ax.XDir, 'YDir', ax.YDir, 'color', 'none');
alpha(a2, 0.5);
colorbar(a2);
set(a2, 'Position', ax.Position);

end

