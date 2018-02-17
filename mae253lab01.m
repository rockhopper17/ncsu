% Andrew Navratil
% MAE 253 Spring 2018
% Lab 1 Pressure Transducer Calculation
% Due 2018-02-05

% clear all vars and plots
close all; clear all; clc;

% import dat files from wed session 1
% Column definitions in the provided data files:
%	P_transducer (psf) | h_manometer (inches) | I_sensor (mA) | T_transducer (degree F)
datainc = load('data/Lab-1_Increasing-Velocity_Wednesday-Session-1_20180124.dat');
datadec = load('data/Lab-1_Decreasing-Velocity_Wednesday-Session-1_20180124.dat');

% constants
hoffset = 0.8;		% in (h_manometer offset based on zero reading from file)
in_to_m = 0.0254;	% 0.0254 m / 1 in
psf_to_pa = 47.88;	% 47.88 pa / 1 psf
rhowater = 997.71;  % kg/m^3
g = 9.8;			% m/s^2

% calculate pressure from manometer readings
pmaninc = ((datainc(:,2) - hoffset) * in_to_m) * g * rhowater;
pmandec = ((datadec(:,2) - hoffset) * in_to_m) * g * rhowater;

% lookup and convert pressure reading from transducer
ptransinc = datainc(:,1) * psf_to_pa;
ptransdec = datadec(:,1) * psf_to_pa;

% get electric current data
iinc = datainc(:,3);
idec = datadec(:,3);

% linear fits - i to pman, ptrans to pman
coeffiinc = polyfit(pmaninc,iinc,1);
coeffidec = polyfit(pmandec,idec,1);
coeffpinc = polyfit(pmaninc,ptransinc,1);
coeffpdec = polyfit(pmandec,ptransdec,1);

% get the curves / values of polynomial for linear fits
valiinc = polyval(coeffiinc,pmaninc);
validec = polyval(coeffidec,pmandec);
valpinc = polyval(coeffpinc,pmaninc);
valpdec = polyval(coeffpdec,pmandec);

% calculate R-square values (goodness of fit)
% we are comparing the 'calculated' values of transducer readings
% to the 'actual' values of the manometer readings
r2pinc = 1 - sum((pmaninc - valpinc).^2 ) / sum((pmaninc - mean(pmaninc)).^2);
r2pdec = 1 - sum((pmandec - valpdec).^2 ) / sum((pmandec - mean(pmandec)).^2);

% plot data for p vs i
fig1 = figure(1);
hold on;
grid on;

xl = [0 1000];		% x range (p values)
yl = [0 20];		% y range (i values)

plot(pmaninc,iinc,'bo');
plot(pmandec,idec,'ro');
plot(xl,polyval(coeffiinc,xl),'g-');
plot(xl,polyval(coeffidec,xl),'c--');
%plot(pmaninc,valiinc,'g-');
%plot(pmandec,validec,'c--');

xlim(xl);
ylim(yl);

title('Pressure Sensor Calibration Curves: Pressure vs Current'); 
xlabel('P_{manometer} (Pa)');
ylabel('I_{sensor} (mA DC)');
legend({'Increasing U_{\infty}','Decreasing U_{\infty}','Linear fit (inc)','Linear fit (dec)'},...
	'Location','Southeast');


% plot data for pressure calculations
fig2 = figure(2);
hold on;
grid on;

plot(pmaninc,ptransinc,'bo');
plot(pmandec,ptransdec,'co');
plot(xl,polyval(coeffpinc,xl),'b-');
plot(xl,polyval(coeffpdec,xl),'c-');
%plot(pmaninc,valpinc,'b--');
%plot(pmandec,valpdec,'c--');
plot(xl,xl,'g-');

xlim(xl);
ylim(xl);

title('Pressure (manometer) vs Pressure (transducer)');
xlabel('P_{manometer} (Pa)');
ylabel('P_{transducer} (Pa)');
legend({'Increasing U_{\infty}','Decreasing U_{\infty}','Linear fit (inc)','Linear fit (dec)','y=x'},...
	'Location','Southeast');
text(525,500,['\leftarrow R^{2} (inc) = ' num2str(r2pinc) ', R^{2} (dec) = ' num2str(r2pdec) '']);

% save plots to jpg
saveas(fig1,'lab01_p_vs_i.jpg');
saveas(fig2,'lab01_p_vs_p.jpg');

