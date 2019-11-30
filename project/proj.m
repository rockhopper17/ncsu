% clear all vars and plots
close all; clear all; clc;

% use s method for writing transfer functions
s = tf('s');

% given fixed parameters
M1 = 10e6; % metric tons converted to kg
k1 = 250e6; % N/m
b1 = 250e3; % N*s/m

% tune these
M2 = 0.1*M1;
k2 = 1;
b2base = b1;

%********************************
% free system (no TMD)
%********************************
%H1 = (1/M1)/(s^2+(b1/M1)*s+(k1/M1));
%impulse(H1)
%figure
%bode(H1)
%figure
%rlocus(H1)

%********************************
% passive sytem
%********************************

% true to run test, false to see plots at tuned value
mintest = true; 

if (mintest == true)
	minsettletime = 1e8; % make this a big number
	
	% first run
	%Mvalues = [0:6]; % this gives max 6
	%kvalues = [0:10]; % this gives 7
	%bvalues = [0:10]; % this gives 6

		% second run, fine tune - this takes awhile, look at optimization
		%Mvalues = [6];
		%kvalues = [6:0.001:8]; % this gives 7.40
		%bvalues = [5:0.001:7]; % this gives 5.65

	% second run, fine tune
	%Mvalues = [6];
	%kvalues = [6:0.1:8]; % this gives 7.4
	%bvalues = [5:0.1:6]; % this gives 5.7

	% third run, more fine tune
	Mvalues = [6];
	kvalues = [7.3:0.01:7.5]; % this gives 7.40
	%bvalues = [5.6:0.01:5.8]; % this gives 5.65
	bvalues = [5.6:0.01:5.8]; % this gives 5.65

	% third run, more fine tune
	%Mvalues = [6];
	%kvalues = [7.39:0.001:7.41]; % this gives 7.405
	%bvalues = [5.64:0.001:5.66]; % this gives 5.640

	% fourth run, more fine tune
	%Mvalues = [6];
	%kvalues = [7.404:0.0001:7.406]; % this gives 7.4054
	%bvalues = [5.639:0.0001:5.641]; % this gives 5.6390
	%bvalues = [5.6:0.01:5.7]; % this gives 5.62

	% fifth run, more fine tune
	%Mvalues = [6];
	%kvalues = [7.4053:0.00001:7.4055]; % this gives 7.40542
	%bvalues = [5.6389:0.00001:5.6391]; % this gives 5.63890

	% sixth run, more fine tune (not changing much here)
	%Mvalues = [6];
	%kvalues = [7.405419:0.000001:7.405421]; % this gives 7.405421
	%bvalues = [5.63889:0.000001:5.63891]; % this gives 5.638890

else
	bvalues = 14.224; % this was calculated using mintest
end

for (Mval = Mvalues)
	M2 = 1*10^Mval;

for (kval = kvalues)
	k2 = 1*10^kval;
	%k2=kval;

for (bval = bvalues)
	%b2 = bval*b2base;
	b2 = 1*10^bval;
	%b2=bval;

	% using state space model for TMD (no a(t) function)
	A = [0 1 0 0; -(k1+k2)/M1 -(b1+b2)/M1 k2/M1 b2/M1; 0 0 0 1;...
		k2/M2 b2/M2 -k2/M2 -b2/M2];
	B = [0; 1/M1; 0; 0];
	C = [1 0 0 0]; % one output: x1
	D = [0];
	sys = ss(A,B,C,D);

	if (mintest == true)
		[y,t] = impulse(sys);

		[pks,locs] = findpeaks(y);
		ysettle = 0.02*max(pks);
		for (idx = 1:length(pks))
			if (pks(idx) <= ysettle)
				break;
			end
		end
		settletime = t(locs(idx));
		if (settletime < minsettletime)
			minsettletime = settletime
			minbval = bval
			minkval = kval
			%minMval = Mval
		end
	else
		tf(sys)
		figure
		impulse(sys)
		figure
		bode(sys)

		damp(sys) % this shows info on damping/freq/time const for each pole
	end
	
end

end % end kvalues
end % end Mvalues

if (mintest == true)
	minsettletime
	%minMval
	minkval
	minbval
end

%********************************
% active system
%********************************

if false

% using full state space model with both F(t) and a(t)
A = [0 1 0 0; -(k1+k2)/M1 -(b1+b2)/M1 k2/M1 b2/M1; 0 0 0 1;...
	k2/M2 b2/M2 -k2/M2 -b2/M2];
B = [0 0; 1/M1 -1/M1; 0 0; 0 1/M2];
C = [1 0 0 0]; % one output: x1
D = [0 0]; % two inputs; F a
sys = ss(A,B,C,D)
[snum,sden] = ss2tf(double(sys.A),double(sys.B),double(sys.C),double(sys.D),1) % X1/F
tfw = tf(snum,sden)
[snum,sden] = ss2tf(double(sys.A),double(sys.B),double(sys.C),double(sys.D),2) % X1/a
tfa = tf(snum,sden)

figure
impulse(sys)
figure
bode(sys)
figure
rlocus(tfw)
figure
rlocus(tfa)

end
