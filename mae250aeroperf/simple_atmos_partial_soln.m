function [h, hG, T, p, rho, a_inf, mu] = simple_atmos(h, option)
%SIMPLE_ATMOS A simplified version of atmospheric calculation
%   Simplified version of earth atmosphere property calculation
%   Given h (geopotential altitude, option=1) or hG (geometric altitude,
%   option=0) in meters, the function will calculate temperature, T, in
%   kelvin, pressure, p, in N/m^2, density, rho, in kg/m^3, 
%   speed of sound , a_inf, in m/s, and coefficient of dynamic viscosity
%   in SI units.
%   Temperature variation from Fig. 3.4 of Anderson's "Introduction to
%   Flight", which is from the 1959 ARDC model atmosphere

% version 2.0, 5 Sep 2017

%%%%%%%%%%%%% Partial solution given below %%%%%%%%%%%

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
    if h(index)<0 | h(index)>100000,
        error('h should be no less than 0  and no more than 100,000');
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
    else,
        % region 7, gradient region
        iregion = 7; % index of the region
        [T(index), p(index), rho(index)] = ...
            grad_layer(iregion,h(index),g0,R,h1,T1,a,p1,rho1);
    end
end

a_inf = sqrt(gamma*R*T);
mu = beta*(T.^1.5)./(T+S);

end

function [T, p, rho] = isothermal(iregion,h,g0,R,h1,T1,p1,rho1)
% ISOTHERMAL Local function to calculate T, p, and rho at given height h
% within region number 'iregion'

rho = rho1(iregion)*exp(term);

end

function [T, p, rho] = grad_layer(iregion,h,g0,R,h1,T1,a,p1,rho1)
% GRAD_LAYER Local function to calculate T, p, and rho at given height h
% within region number 'iregion'

term = -g0/(a(iregion)*R);
T = T1(iregion) + a(iregion)*(h-h1(iregion));
p = p1(iregion)*( (T/T1(iregion))^term );
rho = rho1(iregion)*( (T/T1(iregion))^(term-1) );

end

