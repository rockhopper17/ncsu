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

% loop all calibration images and get intensity values
for cidx = 1:numcfiles
	cnum = calibfilenums(cidx)
	img = imread([calibfldr 'DSC_' num2str(cnum) '.tif']);
	img = rgb2gray(img);

	for ptidx = 1:numpts
		si(cidx,ptidx) = mean(img(imgy(ptidx):imgy(ptidx)+24,...
			imgx(ptidx):imgx(ptidx)+24),'all');
	end
end

% ratios for plotting
pvals = zeros(numcfiles,numpts);
sivals = zeros(numcfiles,numpts);

% calculate and plot calibration points
figure; hold on; grid on;
for cidx = 1:numcfiles
	% get pressure - same for all points in this calibration file
	pvals(cidx,1:numpts) = pd(cidx)/patm;

	% loop points and get intensity values
	for ptidx = 1:numpts
		% si0 (reference intensity) is in si(numcfies,:) for each square,
		%	the last calib file which is atm pressure
		sivals(cidx,ptidx) = si(cidx,ptidx)/si(numcfiles,ptidx);
		plot(pvals(cidx,ptidx),sivals(cidx,ptidx),'*');
	end
end

% calculate calibration curve
%p = polyfit([xvals;ones(200,1)],[yvals;ones(200,1)],1); % get linear fit to data
%p = polyfit(sivals(:),pvals(:),1); % get linear fit to data
%f = polyval(p,sivals(:)); % get points on the linear fit line for plotting
p = polyfit(pvals(:),sivals(:),1); % get linear fit to data
prange = [min(pvals(:)):0.01:max(pvals(:))]; % get pressure ratio range for eval
f = polyval(p,prange); % get points on the linear fit line for plotting

% plot calibration curve
%ph = plot(f,sivals(:),'k--','linewidth',2,'displayname','linear fit');
ph = plot(prange,f,'k--','linewidth',2,'displayname','linear fit');
%xlim([0.2 1]);
legend(ph,'location','northeast');
title('Calibration curve using normalized intensity vs pressure');
ylabel('I/I0');
xlabel('P/P0');

% in part 2, we need to go from y (intensity) to x (pressure), can't use polyval
calibslope = p(1); % slope for y = mx + b
calibintercept = p(2); % intercept


% *************************************************************************** %
% process mach 2 and mach 3 images
% *************************************************************************** %

%p = [-4.20485202342801 5.11829116422546];
%p = [-2.56602733278512 3.3663278228385]; % p for x = sivals
%p = [-0.277011460334893 1.2359192217431]; % p for x = pvals
%calibslope = -0.232115889722576;
%calibintercept = 1.20847509773412;
calibslope = -0.225461666702461;
calibintercept = 1.20890395913576;

% process wind off and on together for mach 2 and mach 3
for idx = [1 3]
	imgoff = imread(mfiles{idx});
	imgoff = rgb2gray(imgoff);
	imgoff = imcrop(imgoff,[3500 800 1200 1800]);
	imgoff = imrotate(imgoff,-3.24989829887425);
	imgon = imread(mfiles{idx+1});
	imgon = rgb2gray(imgon);
	imgon = imcrop(imgon,[3500 800 1200 1800]);
	imgon = imrotate(imgon,-3.24989829887425);

	% one time execution to gather corner points for meshgrid
	%imshow(imgoff);
	%[imgx,imgy] = ginput(4); 
	%pause

	% hard coded corner coordinates after using ginput

	% before cropping
	%imgx = [3640 3720 4644 4536];
	%imgy = [955 2411 2363 887];

	% before rotating
	%imgx = [128 204 1155 1050];
	%imgy = [148 1624 1570 82];
	%rotangle = -atand((imgy(2)-imgy(3))/(imgx(3)-imgx(2)));
	%w = (imgx(3)-imgx(2))/cosd(rotangle); % wedge width
	%h = (imgy(2)-imgy(1))/cosd(rotangle); % wedge height

	% create mesh from hard coded corner points
	xvals = [220:25:1165];
	yvals = [150:25:1625];
	[X,Y] = meshgrid(xvals,yvals); % mesh

	% rotate mesh to correct position
	%xybl = [imgx(2), imgy(2)]; % rotate about bottom left corner
	%R = [cosd(rotangle), -sind(rotangle); sind(rotangle), cosd(rotangle)];
	%XY = floor(xybl' + R * ([X(:) Y(:)]-xybl)');
	%XR = reshape(XY(1,:),size(X));
	%YR = reshape(XY(2,:),size(Y));
	
	% plot mesh to verify
	figure;
	imshow(imgoff);
	hold on;
	plot(X,Y,'-r',X',Y','-r'); 
	drawnow

	% get intensities
	siwoff = zeros(size(X)); % wind off
	siwon = zeros(size(X)); % wind on
	for yidx = 1:size(X,1)
		for xidx = 1:size(X,2)
			xval = X(yidx,xidx); % x or column coord of top left of square
			yval = Y(yidx,xidx); % y or row coord of top left of square
			siwoff(yidx,xidx) = mean(imgoff(yval:yval+24,xval:xval+24),'all');
			siwon(yidx,xidx) = mean(imgon(yval:yval+24,xval:xval+24),'all');
		end
	end

	% calculate ratio I / I0 (wind on / wind off)
	sirat = siwon./siwoff;
	
	% get pressures, multiply ratio by patm to get actual p val
	% from polyfit: p(2) = slope, p(1) = intercept
	pvals = ((sirat - calibintercept)/calibslope) * patm; % x = (y - b)/m
	%pvals = polyval(p,sirat) * patm;

	% contour plot pressures
	colormap('jet');
	psp_plotcontour(gca,X,Y,pvals);
	drawnow
end

