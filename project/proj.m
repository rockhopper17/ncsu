% clear all vars and plots
close all; clear all; clc;

% use s method for writing transfer functions
s = tf('s');

% given fixed parameters
M1 = 10000*9806.65; % metric ton converted to N
k1 = 2.5e8; % N/m
b1 = 2.5e5; % N*s/m
%M1 = 12; % metric ton converted to N
%k1 = 3; % N/m
%b1 = 2; % N*s/m

% tunable parameters
%mfactor = 0.1;
%M2 = realp('M2',mfactor*M1);
%M2.Maximum = 0.1*M1;
%k2 = realp('k2',(1/mfactor)*k1); % match natural frequency
%k2 = realp('k2',1);
%b2 = realp('b2',b1);
M2 = 0.099*M1;
k2 = 1;
b2base = b1;

%********************************
% free system (no TMD)
%********************************
%H1 = (1/M1)/(s^2+(b1/M1)*s+(k1/M1));
%figure(1)
%impulse(H1)
%figure(2)
%bode(H1)

%********************************
% passive sytem
%********************************

% true to run test, false to see plots at tuned value
mintest = true; 

if (mintest == true)
	minsettletime = 1e8; % make this a big number
	minbval = 1;
	bvalues = [1:100]; % first run here, then get more fine tuned
	%bvalues = [55:0.001:57]; % fine tune the value
else
	bvalues = 55.2160; % this was calculated using mintest
end

for (bval = bvalues)
	b2 = bval*b2base;

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
			minsettletime = settletime;
			minbval = bval;
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

if (mintest == true)
	minbval
	settletime
end

%********************************
% active system
%********************************

% using full state space model with both F(t) and a(t)
%A = [0 1 0 0; -(k1+k2)/M1 -(b1+b2)/M1 k2/M1 b2/M1; 0 0 0 1;...
	%k2/M2 b2/M2 -k2/M2 -b2/M2];
%B = [0 0; 1/M1 -1/M1; 0 0; 0 1/M2];
%C = [1 0 0 0]; % one output: x1
%D = [0 0]; % two inputs; F a
%sys = ss(A,B,C,D)
%[snum,sden] = ss2tf(double(sys.A),double(sys.B),double(sys.C),double(sys.D),1) % X1/F
%tfw = tf(snum,sden)
%[snum,sden] = ss2tf(double(sys.A),double(sys.B),double(sys.C),double(sys.D),2) % X1/a
%tfa = tf(snum,sden)

%figure(5)
%impulse(sys)
%figure(6)
%bode(sys)
%figure(7)
%rlocus(tfw)
%figure(8)
%rlocus(tfa)

