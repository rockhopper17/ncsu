% clear all vars and plots
close all; clear all; clc;

% ===============================================
% notes 6.14 - 6.15

% A matrix for Boeing 747
%A = [-0.006868 0.01395 0 -32.2; -0.09055 -0.3151 773.98 0; 0.0001187 -0.001026 -0.4285 0;0 0 1 0]

% eigenvalues in diag of d, eigenvectors in v (dimensional form)
%[v,d] = eig(A)

% convert to non-dimensional form
%v_mod = [v(1,:)/774; v(2,:)/774; v(3,:)*27.31/(2*774); v(4,:)]

% rescale to have u hat,alpha,q hat divided by theta
%spo = v_mod(:,1)/v_mod(4,1)

% convert to cartesian to polar
%[angle_spo, mag_spo] = cart2pol(real(spo),imag(spo));
%[mag_spo angle_spo*180/pi]

% do the same for phugoid
%phugoid = v_mod(:,3)/v_mod(4,3)
%[angle_phugoid, mag_phugoid] = cart2pol(real(phugoid),imag(phugoid));
%[mag_phugoid angle_phugoid*180/pi]
% ===============================================

% pblm 2
%A = [-.045 .036 0 -32.2; -.369 -2.02 176 0; .0019 -0.0396 -2.948 0; 0 0 1 0]
%d = eig(A)  % this just returns eigenvalues
%plot(d,'x')  % plot complex Im vs Re

% pblm 3
t = 0:600;
%y = real(exp((-.003289+i*.06723)*t)); % phugoid
%yenv = exp(-.003289*t);
y = real(exp((.003289+i*.06723)*t)); % phugoid pos real
yenv = exp(.003289*t);
plot(t,y,'k');
hold on;
plot(t,yenv,'k--')
plot(t,-yenv,'k--')

figure;
%t = 0:600;
t = 0:20;
y = real(exp((-.3719+i*.8857)*t)); % spo
yenv = exp(-.3719*t);
plot(t,y,'k');
hold on;
plot(t,yenv,'k--')
plot(t,-yenv,'k--')
