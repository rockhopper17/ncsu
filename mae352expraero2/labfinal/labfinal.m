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

% using thursday group 1
calibfldr = 'datag1thur/calibration/converted/'; % calibration data folder name
m2fldr = 'datag1thur/block2102_theta00/converted/'; % mach 2 data folder name
m3fldr = 'datag1thur/block0818_theta00/converted/'; % mach 3 data folder name
m2woff = [m2fldr 'DSC_2392.tif']; % wind off
m2won = [m2fldr 'DSC_2393.tif']; % wind on
m3woff = [m3fldr 'DSC_2390.tif'];
m3won = [m3fldr 'DSC_2391.tif'];
mfiles = {m2woff m2won m3woff m3won};
calibfilenums = [2375:2389]; 
numcfiles = length(calibfilenums);

% *************************************************************************** %
% calibration
% *************************************************************************** %

% just picking one of the calibration images to choose points
img = imread([calibfldr 'DSC_2389.tif']);
img = rgb2gray(img);
imshow(img);

% one time execution to gather random points
%[imgx,imgy] = ginput(numpts); % get coordinates of random points
%imgx = floor(imgx) % round to get index value in to img
%imgy = floor(imgy)
%pause

% hard coded point indexes
imgx = [2591 2491 2379 2259 2183 2263 2171 2227 2295 2619];
imgy = [2415 2423 2395 2407 2487 2575 2719 2895 2703 2687];

% confirm points with red squares
for idx = 1:numpts
	rectangle('position',[imgx(idx),imgy(idx),25,25],...
	'edgecolor',[1 0 0],'linewidth',2)
end
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
p = polyfit(pvals(:),sivals(:),1); % get linear fit to data
f = polyval(p,pvals(:)); % get points on the linear fit line for plotting

% plot calibration curve
ph = plot(pvals(:),f,'k--','linewidth',2,'displayname','linear fit');
legend(ph,'location','northeast');
title('Calibration curve using normalized intensity vs pressure');
ylabel('I/I0');
xlabel('P/P0');
set(gca,'FontSize',14);
saveas(gcf,'calibration_g1thur.jpg');

% in part 2, we need to go from y (intensity) to x (pressure), can't use polyval
calibslope = p(1); % slope for y = mx + b
calibintercept = p(2); % intercept

% *************************************************************************** %
% process mach 2 and mach 3 images
% *************************************************************************** %

%calibslope = -0.215880065357659;
%calibintercept = 1.22391731155426;

% process wind off and on together for mach 2 and mach 3
for idx = [1 3]
	imgoff = imread(mfiles{idx});
	imgoff = rgb2gray(imgoff);
	imgoff = imcrop(imgoff,[2577 1577 1300 1900]);
	imgon = imread(mfiles{idx+1});
	imgon = rgb2gray(imgon);
	imgon = imcrop(imgon,[2577 1577 1300 1900]);

	% one time execution to gather corner points for meshgrid
	%imtool(imgoff);
	%pause
	
	% create mesh from hard coded corner points
	xvals = [110:25:1210]; % capture 25x25 square mean
	yvals = [60:25:1835];
	[X,Y] = meshgrid(xvals,yvals); % mesh

	% plot mesh to verify
	%figure;
	%imshow(imgoff);
	%hold on;
	%plot(X,Y,'-r',X',Y','-r'); 
	%drawnow; pause;

	% get intensities
	for yidx = 1:size(X,1)
		for xidx = 1:size(X,2)
			xval = X(yidx,xidx); % x or column coord of top left of square
			yval = Y(yidx,xidx); % y or row coord of top left of square
			siwoff = mean(imgoff(yval:yval+24,xval:xval+24),'all'); % wind off
			siwon = mean(imgon(yval:yval+24,xval:xval+24),'all'); % wind on
			sirat = siwon/siwoff; % I/I0

			% theoretical calculation
			% P1 from lab 2 shows Mach 3: P1 = 2.00
			%					  Mach 2: P1 = 7.37
			% theta-beta-mach gives Mach 3: beta=27deg > M1N=1.36
			%						Mach 2: beta=39deg > M1N=1.26
			% NS tables give Mach 3: P2/P1=1.99
		    %			  	 Mach 2: P2/P1=1.69
			% Expected Pressure Values Mach 3: P=3.98
			%						   Mach 2: P=12.45
			
			% calculate pressure from slope and intercept of calibration curve
			pvals(yidx,xidx) = ((sirat - calibintercept)/calibslope) * patm;
		end
	end

	% contour plot pressures
	figure;
	imshow(imgoff);
	hold on;
	colormap('jet');
	psp_plotcontour(gca,X,Y,pvals);
	set(gca,'FontSize',14);
	if idx == 1
		title('Mach 2 Pressure Contour [psi] (Expected = 12.45 psi)');
		caxis([5 20]);
		drawnow;
		saveas(gcf,'mach2_g1thur.jpg');
	else
		title('Mach 3 Pressure Contour [psi] (Expected = 3.98 psi)');
		caxis([0 8]);
		drawnow;
		saveas(gcf,'mach3_g1thur.jpg');
	end
end

