function [h, hG, T, p, rho, a_inf, mu] = simple_atmos(h, option)
%SIMPLE_ATMOS This is a TEMPLATE (with many portions removed) to a
%   Simplified version of earth atmosphere property calculation
%   Given h (geopotential altitude, option=1) or hG (geometric altitude,
%   option=0) in meters, the function will calculate temperature, T, in
%   kelvin, pressure, p, in N/m^2, density, rho, in kg/m^3, 
%   speed of sound , a_inf, in m/s, and coefficient of dynamic viscosity
%   in SI units.
%   Temperature variation from Fig. 3.4 of Anderson's "Introduction to
%   Flight", which is from the 1959 ARDC model atmosphere

% version 2.0, 5 Sep 2017

% Matlab help
%
% Getting started guides
% http://www.mathworks.com/help/matlab/getting-started-with-matlab.html

%
% element-by-element multiplication:
% http://www.mathworks.com/help/matlab/ref/times.html?searchHighlight=times
% Element-wise power
% http://www.mathworks.com/help/matlab/ref/power.html
% Element-wise divide
% http://www.mathworks.com/help/matlab/ref/rdivide.html
%
% Function
% http://www.mathworks.com/help/matlab/ref/function.html?searchHighlight=function
%
% if-elseif-else-end
% http://www.mathworks.com/help/matlab/ref/if.html?searchHighlight=if
%
% for loop
% http://www.mathworks.com/help/matlab/ref/for.html?searchHighlight=for
%
% or logical (this or that)
% http://www.mathworks.com/help/matlab/ref/or.html?searchHighlight=or

% Constants from 1976 US standard atmosphere
% https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19770009539.pdf
% (note errata sheet at the end of the document)
g0 = 9.80665;      % sea-level acc. due to gravity in m/s^2
r = 6.356766e6;    % radius of earth in m

p_s = 1.01325e5;   % sea-level pressure, N/m^2
rho_s = 1.2250;    % sea-level density, kg/m^3
T_s = 288.15;      % sea-level temperature, kelvin

R = 287.05;        % specific gas constant for air, J/(kg.K)
                   % from https://en.wikipedia.org/wiki/Gas_constant#Specific_gas_constant

gamma = 1.4;       % ratio of specific heats
S = 110;           % Sutherland's constant in kelvin
beta = 1.458e-6;   % constant for viscosity, SI units

if option==1,
    % altitude is geopotential, calculate geometric
    hG = r*h./(r-h);
elseif option==0,
    % altitude is geometric, copy h to hG and
    % convert geometric altitude to geopotential
    hG = h;
    h = hG.*(r./(r+hG));
else,
    error('OPTION has to be 0 or 1');
end

% Make sure that h is a column array, otherwise give error message
[numrow numcol] = size(h);
if numcol~=1,
    error('h should be a column vector');
end

% Pre-allocate T, p, rho vectors and initialize them to zero
% a_inf is speed of sound in m/s and 
%     mu is coeff of dynamic viscosity in SI units
T = h*0;
p = h*0;
rho = h*0;
a_inf = h*0;
mu = h*0;

% Calculate the base values for h, T, p, and rho for the 7 regions of the
% atmosphere. The variables are h1, T1, p1, and rho1, each being a 7x1
% column array.
%
% h1 and T1 come from Fig. 3.4 of Anderson's book,
% which is from the 1959 ARDC model atmosphere
% a = dT/dh is also a 7x1 array from Fig. 3.4
h1 = [0; 11000; 25000; 47000; 53000; 79000; 90000];
T1 = [288.16; 216.66; 216.66; 282.66; 282.66; 165.66; 165.66];
a = [-6.5e-3; 0; 3e-3; 0; -4.5e-3; 0; 4e-3];

% Pre-allocate p1 and rho1 vectors
p1 = h1*0;
rho1 = h1*0;
p1(1) = p_s;
rho1(1) = rho_s;

% Bottom of region 2 is top of region 1, ans so on. Use isothermal/gradient
% equations for p and rho to get values for bottom of a layer (top of
% previous layer)

% calculate p and rho for base of region 2; use gradient eqns for region 1
iregion = 1; % index of the region for which top properties are calculated
[T_discard, p1(iregion+1), rho1(iregion+1)] = ...
    grad_layer(iregion,h1(iregion+1),g0,R,h1,T1,a,p1,rho1);

% calculate p and rho for base of region 3; use isotherm eqns for region 2
iregion = 2; % index of the region for which top properties are calculated
[T_discard, p1(iregion+1), rho1(iregion+1)] = ...
    isothermal(iregion,h1(iregion+1),g0,R,h1,T1,p1,rho1);

% calculate p and rho for base of region 4; use gradient eqns for region 3
iregion = 3; % index of the region for which top properties are calculated
[T_discard, p1(iregion+1), rho1(iregion+1)] = ...
    grad_layer(iregion,h1(iregion+1),g0,R,h1,T1,a,p1,rho1);

% calculate p and rho for base of region 5; use isotherm eqns for region 4
iregion = 4; % index of the region for which top properties are calculated
[T_discard, p1(iregion+1), rho1(iregion+1)] = ...
    isothermal(iregion,h1(iregion+1),g0,R,h1,T1,p1,rho1);

% calculate p and rho for base of region 6; use gradient eqns for region 5
iregion = 5; % index of the region for which top properties are calculated
[T_discard, p1(iregion+1), rho1(iregion+1)] = ...
    grad_layer(iregion,h1(iregion+1),g0,R,h1,T1,a,p1,rho1);

% calculate p and rho for base of region 7; use isotherm eqns for region 6
iregion = 6; % index of the region for which top properties are calculated
[T_discard, p1(iregion+1), rho1(iregion+1)] = ...
    isothermal(iregion,h1(iregion+1),g0,R,h1,T1,p1,rho1);

for index=1:numrow,
    if h(index)<0 || h(index)>100000,
        error('h should be no less than 0 and no more than 100,000');
    elseif h(index)<h1(2),
        % region 1, gradient region
        iregion = 1; % index of the region
        [T(index), p(index), rho(index)] = ...
            grad_layer(iregion,h(index),g0,R,h1,T1,a,p1,rho1);
    elseif h(index)<h1(3),
        % region 2, isothermal region
        iregion = 2; % index of the region
        [T(index), p(index), rho(index)] = ...
            isothermal(iregion,h(index),g0,R,h1,T1,p1,rho1);
    elseif h(index)<h1(4),
        % region 3, gradient region
        iregion = 3; % index of the region
        [T(index), p(index), rho(index)] = ...
            grad_layer(iregion,h(index),g0,R,h1,T1,a,p1,rho1);
    elseif h(index)<h1(5),
        % region 4, isothermal region
        iregion = 4; % index of the region
        [T(index), p(index), rho(index)] = ...
            isothermal(iregion,h(index),g0,R,h1,T1,p1,rho1);
    elseif h(index)<h1(6),
        % region 5, gradient region
        iregion = 5; % index of the region
        [T(index), p(index), rho(index)] = ...
            grad_layer(iregion,h(index),g0,R,h1,T1,a,p1,rho1);
    elseif h(index)<h1(7),
        % region 6, isothermal region
        iregion = 6; % index of the region
        [T(index), p(index), rho(index)] = ...
            isothermal(iregion,h(index),g0,R,h1,T1,p1,rho1);
    else
        % region 7, gradient region
        iregion = 7; % index of the region
        [T(index), p(index), rho(index)] = ...
            grad_layer(iregion,h(index),g0,R,h1,T1,a,p1,rho1);
    end
end

a_inf = sqrt(gamma*R*T);
mu = ( (beta*T.^(3/2)) ./ (T+S) ); 

end

function [T, p, rho] = isothermal(iregion,h,g0,R,h1,T1,p1,rho1)
% ISOTHERMAL Local function to calculate T, p, and rho at given height h
% within region number 'iregion'

term = -( g0/(R*T1(iregion)) )*(h-h1(iregion));
T = T1(iregion);
p = p1(iregion)*exp(term);
rho = rho1(iregion) * exp(term); 

end

function [T, p, rho] = grad_layer(iregion,h,g0,R,h1,T1,a,p1,rho1)
% GRAD_LAYER Local function to calculate T, p, and rho at given height h
% within region number 'iregion'

term = (g0 / (R * a(iregion) ) );
T = T1(iregion) + ( a(iregion) .* (h - h1(iregion) ));
p = p1(iregion) * (T ./ T1(iregion)) .^ -(term);
rho = rho1(iregion) * (T ./ T1(iregion)) .^ -(term + 1);

end

