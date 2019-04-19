% Tuesday Group 4
% MAE 352 Expr Aero 2 Spring 2019
% Final Project: Pressure Measurement using Pressure Sensitive Paint
% Due 2019-04-29

% clear all vars and plots
close all; clear all; clc; format longg;

% *************************************************************************** %
% constants
% *************************************************************************** %
patm = 14.69595; % Patm pulled from data.dat file in block0818_theta00, also p0
numpts = 10; % number of points to grab for calibration

% using tuesday group 2 data
calibfldr = 'datag2/calibration/converted/'; % calibration data folder name
m2fldr = 'datag2/block2102_theta00/converted/'; % mach 2 data folder name
m3fldr = 'datag2/block0818_theta00/converted/'; % mach 2 data folder name
m2woff = [m2fldr 'DSC_2288.tif']; % wind off
m2won = [m2fldr 'DSC_2289.tif']; % wind on
m3woff = [m3fldr 'DSC_2286.tif'];
m3won = [m3fldr 'DSC_2287.tif'];
mfiles = {m2woff m2won m3woff m3won};

% pull files in correct order using num from file name
calibfilenums = [2266:2285]; 
numcfiles = length(calibfilenums);

% *************************************************************************** %
% calibration
% *************************************************************************** %
if false

% just picking one of the calibration images to choose points
img = imread([calibfldr 'DSC_2285.tif']);
img = rgb2gray(img);
imshow(img);

% one time execution to gather random points
%[imgx,imgy] = ginput(numpts); % get coordinates of random points
%imgx = floor(imgx) % round to get index value in to img
%imgy = floor(imgy)
%pause

% hard coded point indexes
imgx = [2604 2488 2260 2208 2268 2416 2480 2700 2476 2664];
imgy = [2219 2247 2311 2575 2875 3083 2867 2583 2479 2283];

% confirm points with red squares
for idx = 1:numpts
	rectangle('position',[imgx(idx),imgy(idx),25,25],...
	'edgecolor',[1 0 0],'linewidth',2)
end
%pause; % pause execution so we can confirm image, hit enter when ready
drawnow

% pull in calibration pressure data
pd = load([calibfldr '../calibration.txt']);
pd = pd + patm; % gauge pressures plus atm pressure

si = zeros(numcfiles,numpts); % signal intensity values, mean of 25x25 square

% loop all calibration images to get calibration curve for pressure
for cidx = 1:numcfiles
	cnum = calibfilenums(cidx);
	img = imread([calibfldr 'DSC_' num2str(cnum) '.tif']);
	img = rgb2gray(img);

	for siidx = 1:numpts
		si(cidx,siidx) = mean(img(imgx(siidx):imgx(siidx)+24,...
			imgy(siidx):imgy(siidx)+24),'all');
		cidx
		siidx
		si(cidx,siidx)
	end
end

% combined data for plotting and linear regression
xvals = zeros(numcfiles*numpts,1);
yvals = zeros(numcfiles*numpts,1);

% calculate and plot calibration points
% si0 (reference intensity) is in si(numcfies,:) for each square,
%	the last calib file which is atm pressure
figure;
hold on; grid on;
for cidx = 1:numcfiles
	for siidx = 1:numpts
		xvals((cidx-1)*numpts + siidx) = pd(cidx)/patm;
		yvals((cidx-1)*numpts + siidx) = si(cidx,siidx)/si(numcfiles,siidx);
		plot(xvals((cidx-1)*numpts + siidx),yvals((cidx-1)*numpts + siidx),'*');
	end
end

% calculate calibration curve
%p = polyfit([xvals;ones(200,1)],[yvals;ones(200,1)],1); % get linear fit to data
p = polyfit(xvals,yvals,1); % get linear fit to data
f = polyval(p,xvals); % get points on the linear fit line for plotting

% remove outliers and get a second better fit
%xfilt = find(abs(f - yvals) < 0.2); % filter to get only points within 0.2 of curve
%p = polyfit(xvals(xfilt),yvals(xfilt),1);
%f = polyval(p,xvals);

% plot calibration curve
ph = plot(xvals,f,'k--','linewidth',2,'displayname','linear fit');
legend(ph,'location','northeast');
title('Calibration curve using normalized intensity vs pressure');
ylabel('I/I0');
xlabel('P/P0');

% in part 2, we need to go from y (intensity) to x (pressure), can't use polyval
calibslope = p(1); % slope for y = mx + b
calibintercept = p(2); % intercept

end
% *************************************************************************** %
% process mach 2 and mach 3 images
% *************************************************************************** %

p = [-0.277011460334893 1.2359192217431];
%calibslope = -0.232115889722576;
%calibintercept = 1.20847509773412;

% process wind off and on together for mach 2 and mach 3
for idx = [1 3]
	imgoff = imread(mfiles{idx});
	imgoff = rgb2gray(imgoff);
	imgoff = imcrop(imgoff,[3500 800 1200 1800]);
	imgon = imread(mfiles{idx+1});
	imgon = rgb2gray(imgon);
	imgon = imcrop(imgon,[3500 800 1200 1800]);
	figure;
	imshow(imgoff);
	hold on;

	% one time execution to gather corner points for meshgrid
	%[imgx,imgy] = ginput(4); 

	% hard coded corner coordinates after using ginput
	%imgx = [3640 3720 4644 4536];
	%imgy = [955 2411 2363 887];
	imgx = [128 204 1155 1050];
	imgy = [148 1624 1570 82];

	% create a mesh and rotate to correct position
	% pt 1 = top left, pt 2 = bottom left, pt 3 = bottom right
	rotangle = -atand((imgy(2)-imgy(3))/(imgx(3)-imgx(2)));
	w = (imgx(3)-imgx(2))/cosd(rotangle); % wedge width
	h = (imgy(2)-imgy(1))/cosd(rotangle); % wedge height
	xvals = [imgx(2):25:imgx(2)+w];
	yvals = [imgy(1):25:imgy(1)+h];
	[X,Y] = meshgrid(xvals,yvals); % mesh
	xybl = [imgx(2), imgy(2)]; % rotate about bottom left corner
	R = [cosd(rotangle), -sind(rotangle); sind(rotangle), cosd(rotangle)];
	XY = floor(xybl' + R * ([X(:) Y(:)]-xybl)');
	XR = reshape(XY(1,:),size(X));
	YR = reshape(XY(2,:),size(Y));
	plot(XR,YR,'-r',XR',YR','-r'); % display mesh to verify
	drawnow

	% get intensities
	siwoff = zeros(size(XR)); % wind off
	siwon = zeros(size(XR)); % wind on
	for siy = 1:size(XR,1)
		for six = 1:size(XR,2)
			siwoff(siy,six) = mean(imgoff(XR(six):XR(six)+24,...
				XY(siy):XY(siy)+24),'all');
			siwon(siy,six) = mean(imgon(XR(six):XR(six)+24,...
				XY(siy):XY(siy)+24),'all');
		end
	end

	% calculate ratio I / I0 (wind on / wind off)
	sirat = siwon./siwoff;
	
	% get pressures
	% from polyfit: p(2) = slope, p(1) = intercept
	pvals = (sirat - p(2))*patm/p(1);

	% contour plot pressures
	colormap('jet');
	psp_plotcontour(gca,XR,YR,pvals);
	drawnow
end

