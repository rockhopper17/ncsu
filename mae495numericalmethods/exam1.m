close all; clear all; clc;

% test
%a(1,:) = [2 1 0 -1 -2];
%a(2,:) = [1 2 1 0 -1];
%a(3,:) = [0 1 2 1 0];
%a(4,:) = [-1 0 1 2 1];
%a(5,:) = [-2 -1 0 1 2];

%b = ones(5,1)*2;

% pblm2
%a = [2 1 0;1 2 1;0 1 2];
%b = ones(3,1);

% pblm 3
%n = 20;
%n = 200;

%for i=1:n
	%for j=1:n
		%if i==j
			%a(i,j) = 2;
		%elseif j==i-1 | j==i+1
			%a(i,j) = -1;
		%else
			%a(i,j) = 0;
		%end
	%end
%end

%h = (2*pi)/(n+1);
%for i=1:n
	%ih(i) = i*h;
	%b(i) = h*h * sin(i*h);
%end

%x=a\b';

%plot(ih,x);

d=load('pblm3n20.txt');
figure;
plot(d(:,1),d(:,2));
grid on;
title('n=20');
ylabel('x_{i}');
xlabel('ih');
set(gca,'FontSize',16);

d=load('pblm3n200.txt');
figure;
plot(d(:,1),d(:,2));
grid on;
title('n=200');
ylabel('x_{i}');
xlabel('ih');
set(gca,'FontSize',16);
