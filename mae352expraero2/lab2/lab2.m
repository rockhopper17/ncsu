% Andrew Navratil
% MAE 352 Expr Aero 2 Spring 2019
% Lab 2 Shock Wave Analysis
% Due 2019-02-18

% clear all vars and plots
close all; clear all; clc;

% *************************************************************************** %
% constants, lookup data, and data structures %
% *************************************************************************** %
gamma = 1.4;  % ratio spec heats for air @stp

% blocks and thetas
blocknums = [818 895 1012 1286 1667 2102 2465];
thetas = [0 5 10 15 20];
numb = numel(blocknums);
numt = numel(thetas);

% lab 1: block numbers corresponding to file names
blockmin = 400;
blockmax = 2600;
blocknums1 = [blockmin:200:blockmax];
numb1 = numel(blocknums1);

% mach numbers for theoretical plot
machnums = [1.1 1.2 1.3 1.4 1.6 1.8 2.0 2.25 2.5 3.0 4.0 6.0 8.0 15];
numm = numel(machnums);

% theta-beta-mach relationship for fsolve 
f_tbm = @(M,t,b) (tan(b) .* ( ( ((gamma+1) .* M.^2) ./ (2*(M.^2 .* sin(b).^2 - 1) ) )  - 1)) - cot(t);
opts = optimset('Diagnostics','off', 'Display','off');

% theta-beta-mach formula for zero degree wedge angle
f_t0 = @(b) csc(b);

% another theta-beta-mach for theoretical calculation plots, to be evaluated directly for theta
f_t = @(M,b) acot( (tan(b) .* ( ( ((gamma+1) .* M.^2) ./ (2*(M.^2 .* sin(b).^2 - 1) ) )  - 1)) );

% isentropic relation for direct evaluation
f_isen = @(p1,p01) sqrt( ( (p01./p1).^((gamma-1)/gamma) - 1 ) .* (2/(gamma-1))  );

% struct for t-b-m values with block num
z = num2cell(zeros(1,numb * numt)');
bvals = num2cell(repelem(blocknums,numt)');
tvals = num2cell(repmat(thetas,1,numb)');
tbm = struct('blocknum',bvals,'theta',tvals,'beta',z,'M',z,'M_isen',z);

% lab 1: array for mach numbers
M_isen1 = zeros(1,numb1);

% *************************************************************************** %
% perform lab 1 analysis to get mach num vs block num for isentropic relation
% use the values from the 2nd order polyfit as initial guess values for tbm fsolve
% *************************************************************************** %

% Lab 1: Column definitions in the provided 'calibration_*.txt' data files:
% time (s) | P_01 (psi) | P_1 (psi) | P_02 (psi) | Patm (psi) | T_01 (degree F)
for bidx = 1:numb1
	d = load(sprintf('../lab1/data/calibration_%d.txt',blocknums1(bidx)));

	% remove all rows before 2.5 seconds
	d(d(:,1) < 2.5, :) = [];

	% pull out p1 and p01, adding patm to each
	p1 = d(:,3) + d(:,5);
	p01 = d(:,2) + d(:,5);

	% calculate average M_isen
	M_isen1(bidx) = mean(f_isen(p1,p01));
end

% perform the polyfit analysis on lab 1 data using 2nd order polynomial
% excluding first two outliers
[coeff_isen, ~, mu_isen] = polyfit(blocknums1(3:end),M_isen1(3:end),2);
fit_isen = polyval(coeff_isen,[blockmin:1:blockmax],[],mu_isen);

% set initial guess values for tbm fsolve
x0 = fit_isen(blocknums - blockmin);

% *************************************************************************** %
% loop all blocknum-theta combinations %
% folders for each combo should be in the main data folder %
% *************************************************************************** %
for btidx = 1:numel(tbm)
	% get this blocknum and theta
	blocknum = tbm(btidx).blocknum;
	theta = tbm(btidx).theta;

	% beta angle
	beta = 0;

	% get images
	datafldr = sprintf('all-data/block%04d_theta%02d', blocknum, theta);
	images = dir(fullfile(datafldr, '*.jpg'));

	% vars to hold info for best image
	betabest = 0;
	rsqbest = -1000;
	imgbest = 0;
	ibest = 1;
	fbest = 0;

	% loop all images and perform edge processing to get beta, choose best with r-squared analysis
	for i = 1:numel(images)
		img_g = imread(fullfile(datafldr,images(i).name));

		% investigation of tolerance thresholds still showed .14 to be best multiplier
		variation1 = diff(img_g);
		variation2 = diff(img_g, 2);
		edgeTol1 = max(mean(variation1));
		edgeTol2 = max(mean(variation2));
		threshold = mean([edgeTol1, edgeTol2])*.14;

		% perform edge detection
		img = edge(img_g, 'canny', threshold);
		[rows,cols] = size(img);
		xall = [1:cols];

		% remove small clusters of white pixels
		img = bwareaopen(img,50);

		% crop image, with some block/theta specific crops
		if blocknum == 2102 & theta == 0
			img = imcrop(img,[0.4*cols 0.4*rows 0.4*cols 0.4*rows]);
		else
			img = imcrop(img,[0.2*cols 0.2*rows 0.6*cols 0.6*rows]);
		end

		% find uppermost white pixel in each column (ignore 1's, that means col likely had none)
		[~,y] = max(img,[],1); % this returns one val per column
		xfilt = find(y ~= 1); % get col indexes of valid rows
		y = y(xfilt);

		% perform a linear first order fit on valid points, and construct line through all columns
		[p, ~, mu] = polyfit(xfilt, y, 1);
		f = polyval(p,xfilt,[],mu); 

		% remove additional outliers: any points more than 50 away from first best fit line
		xfilt2 = find(abs(f - y) < 50);
		y = y(xfilt2);

		% perform second fit and evaluate across all x vals
		[p, ~, mu] = polyfit(xfilt2, y, 1);
		f = polyval(p,xall,[],mu); 
		
		% calculate slope using first two points of 1st order fit line
		beta = atan(f(2) - f(1));

		% perform r-squared analysis to choose best image
		yresid = y - f(xfilt2);
		SSresid = sum(yresid.^2);
		SStotal = (length(y)-1) * var(f(xfilt2));
		rsq = 1 - SSresid/SStotal;

		% if we have a better rsq, use this beta angle
		% ensure beta angle is greater than wedge angle so we aren't grabbing wedge line
		if rsq > rsqbest & rad2deg(beta) > (theta + 2)
			betabest = beta;
			rsqbest = rsq;
			imgbest = img;
			ibest = i;
			fbest = f;
		end
	end

	% set beta to betabest
	beta = betabest;

	% show the edge detection image with shockwave line
	figure;
	imshow(imgbest);
	hold on;
	plot(xall, fbest, 'g-');
	title(sprintf('block %d theta %d image %s rsq %f',blocknum,theta,images(ibest).name,rsqbest));
	drawnow

	% evaluate theta-beta-mach relationship for mach number
	if theta == 0
		machnum = f_t0(beta);
	else
		bidx = find(blocknums == blocknum);
		machnum = fsolve(@(M) f_tbm(M, deg2rad(theta), beta), x0(bidx), opts);
	end

	% insert data into tbm
	tbm([tbm.blocknum] == blocknum & [tbm.theta] == theta).beta = rad2deg(beta); 
	tbm([tbm.blocknum] == blocknum & [tbm.theta] == theta).M = machnum;

	% calculate mach number using pressure data

	% Lab 2: Column definitions in the data.dat files in each folder:
	% time (s) | P_01 (psi) | P_1 (psi) | Patm (psi) | T_01 (degree F)

	% import data, load will auto remove two header rows
	d = load(sprintf('all-data/block%04d_theta%02d/data.dat', blocknum, theta));

	% remove all rows before 2.5 seconds
	d(d(:,1) < 2.5, :) = [];

	% pull out p1 and p01, adding patm to each
	p1 = d(:,3) + d(:,4);
	p01 = d(:,2) + d(:,4);

	% calculate average M_isen and enter into tbm
	tbm([tbm.blocknum] == blocknum & [tbm.theta] == theta).M_isen = mean(f_isen(p1,p01));

	% display values
	tbm([tbm.blocknum] == blocknum & [tbm.theta] == theta)
end

% *************************************************************************** %
% plot theta-beta-mach data %
% *************************************************************************** %
figure;
cmap = flipud(jet(numb));
ph = zeros(numb,1);
%figure('position',[200 200 800 800]);
for bidx = 1:numb
	blocknum = blocknums(bidx);
	tvals = [tbm([tbm.blocknum] == blocknum).theta];
	bvals = [tbm([tbm.blocknum] == blocknum).beta];
	ph(bidx) = plot(tvals,bvals,'o','color',cmap(bidx,:),...
		'DisplayName',['Block ' num2str(blocknum)],'MarkerSize',8);
	hold on;
end

% plot theoretical data
b = deg2rad([0:0.1:90]); % beta angles 0 through 90 deg
for midx = 1:numm
	M = machnums(midx);
	t = f_t(M,b);

	plot(rad2deg(t),rad2deg(b),'-k');
	hold on;

	% plot the mach num label
	[tmax,tmaxidx] = max(t);
	text(rad2deg(tmax),rad2deg(b(tmaxidx)),num2str(M),'FontSize',14);
end

set(gca,'Color', [0.7,0.7,0.7],'FontSize',14); % gray background
title({'Shock wave angle from Schlieren image edge detection versus wedge angle',...
	'by block with theorectical comparison'},'FontSize',16);
ylabel('Shock wave angle, \beta [deg]','FontSize',14);
xlabel('Deflection (wedge) angle, \theta [deg]','FontSize',14);
grid on;
legend(ph,'location','southeast','FontSize',14);
axis([0 50 0 90]);

% *************************************************************************** %
% plot mach num vs block num %
% *************************************************************************** %
figure;
cmap = jet(numt+2);
for tidx = 1:numt
	theta = thetas(tidx);
	blkvals = [tbm([tbm.theta] == theta).blocknum];
	mvals = [tbm([tbm.theta] == theta).M];
	misenvals = [tbm([tbm.theta] == theta).M_isen];
	plot(blkvals,mvals,'o','color',cmap(tidx,:),...
		'DisplayName',['Theta ' num2str(theta) ' \theta-\beta-M'],'MarkerSize',8);
	hold on;
	plot(blkvals,misenvals,'^','color',cmap(tidx,:),...
		'DisplayName',['Theta ' num2str(theta) ' isen'],'MarkerSize',8);
end

plot(blocknums1,M_isen1,'*','color',cmap(end,:),'DisplayName','Lab 1 isen','MarkerSize',8);
plot([blockmin:1:blockmax],fit_isen,'-','color',cmap(end,:),'DisplayName','Lab 1 2nd order polyfit');

set(gca,'Color', [0.7,0.7,0.7],'FontSize',14); % gray background
title('Mach number vs block number for \theta-\beta-M and isentropic relation from pressures','FontSize',16);
ylabel('Mach Number','FontSize',14);
xlabel('Block Number','FontSize',14);
grid on;
legend('location','northeast','FontSize',14);
axis([blockmin blockmax 1 3.5]);

