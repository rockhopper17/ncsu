function [ftform,fpeaks] = CalcFourierTransform(t, sigx, numpeaks)
%
% CalcFourierTransform calculate the discrete fourier transform of input signal
%
% inputs:
%	t:			time values
%	sigx:		signal amplitude values (velocities)
%	numpeaks: 	int number of frequency peaks to calculate (optional, default=3)
%
% outputs:
%	ftform:		fourier transform frequencies and magnitudes
%	fpeaks:		peak frequencies and magnitudes

% perform a fourier transform on a signal
% currently using discrete fourier transform algorithm, no fft
% see Lyons - Understanding Digital Signal Processing - Chp 3

% do some basic input validation
if nargin > 3
	error('CalcFourierTransform:TooManyInputs','requires at most 3 inputs');
elseif ~isequal(size(t),size(sigx))
	error('CalcFourierTransform:UnequalVectors','number of elements in t and sigx must be equal');
end

% set number of peaks to calculate - default for optional parameter
if nargin == 2
	numpeaks = 3;
end

% calculate sample rate
numt = length(t); % number of data points (time values)
dt = mean(diff(t));
fs = 1 / dt; % sample rate

% fourier transform variables
fres = fs/numt; % frequency resolution - actual freq lines to calculate
numfreqs = numt/2; % number of frequencies that can be measured
freqrange = [0:fres:fres*(numfreqs-1)]; % frequency buckets

ftform = [freqrange; zeros(1,numfreqs)]'; % fourier transform frequencies and magnitudes
fpeaks = zeros(numpeaks,2); % peak frequencies and magnitudes for numpeaks

% compute fourier transform	
for m = 0:numfreqs-1
	% perform summation using exponential form
	for n = 0:numt-1
		ftform(m+1,2) = ftform(m+1,2) + (sigx(n+1) * exp(-j*2*pi*n*m/numt) );
	end
end

% calculate scaled magnitude
ftform(:,2) = abs(ftform(:,2)/numt); % note: if value is complex, abs returns magnitude

% find magnitude peaks - corresponds to distinct frequencies in signal
% ignore DC term (0Hz term, the average of all samples) start at 2nd index
for m = 2:numfreqs
	cur = ftform(m,2); % current mag
	prev = ftform(max(1,m-1),2); % previous mag
	next = ftform(min(numfreqs,m+1),2); % next mag
	
	% first see if value is a local maxima
	if (cur > prev & cur > next)
		% then loop to see if it's one of the new top peaks
		for n = 1:numpeaks
			if (cur > fpeaks(n,2))
				% push down all previous peaks
				for n2 = numpeaks:-1:n+1
					fpeaks(n2,:) = fpeaks(n2-1,:);
				end

				% reset nth peak
				fpeaks(n,:) = ftform(m,:);
				break;
			end
		end
	end
end

