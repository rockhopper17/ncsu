% MAE 253 Spring 2018
% Final Project
% Due 2018-05-09

% clear all vars and plots
close all; clear all; clc;

% constants / conversions / coefficients
in_to_mm = 25.4;		% 25.4 mm / 1 in
psf_to_pa = 47.88;		% 47.88 pa / 1 psf
inHg_to_pa = 3387;		% 3387 pa / 1 inHg
R = 287;				% gas const air J / kg K
degF_to_degR = 460;		% deg Fahrenheit to deg Rankine (add this, don't multiply)
degR_to_K = 1/1.8;		% deg Rankine to Kelvin
DataFolderName = 'data/FinalProject/';		%data folder name, will have subfolders at each psf with files
%DataFolderName = 'data/test/';		% data folder name, will have subfolders at each psf with files
DataFileExtensions = '*.txt';				% data file extensions, txt here (could be dat, etc)

% init some collections
pd = [];	% data: y, z, pDynamic, pTotal, vel
pdAll = {}; % hold pd for each subfolder (qinf)

% get list of subfolders (exclude . and ..)
dataFolder = dir(DataFolderName);
subFolders = dataFolder([dataFolder.isdir]);
subFolders(ismember( {subFolders.name},{'.','..'})) = [];

% iterate all files with specified extension(s) in all subfolders and process data
%for subfolder = subFolders.name'
for idxi = 1:numel(subFolders)
	pd = [];
	files = dir(fullfile( subFolders(idxi).folder, subFolders(idxi).name, DataFileExtensions));

	for idxj = 1:numel(files)
		data = load(fullfile(files(idxj).folder, files(idxj).name));
		
		yRaw = data(4:43,:);
		zRaw = data(44:83,:);
		pgaugeRaw = data(84:123,:);
		qinfRaw = data(124,:);
		tempRaw = data(125,:);
		pstaticRaw = data(126,:);

		y = yRaw * in_to_mm;
		z = zRaw * in_to_mm;
	
		% using abs here due to anomalous negative reading in q_0-5/z-loc_13.txt, row 88 column 21	
		pDynamic = abs(pgaugeRaw) * psf_to_pa;

		pTotal = (pgaugeRaw * psf_to_pa) + (pstaticRaw * inHg_to_pa);

		tempK = (tempRaw + degF_to_degR) * degR_to_K;
		rho = pTotal ./ (R * tempK);
		vel = sqrt(2 * pDynamic ./ rho);
	
		% flatten matrices so we just have one column for each
		y = y(:);
		z = z(:);
		pDynamic = pDynamic(:);
		pTotal = pTotal(:);
		vel = vel(:);

		% average duplicate entries and add to pd
		[C,ia,idx] = unique([y z],'rows');
		avgDynamic = accumarray(idx,pDynamic,[],@mean);
		avgTotal = accumarray(idx,pTotal,[],@mean);
		avgVel = accumarray(idx,vel,[],@mean);
		pd = [pd; C avgDynamic avgTotal avgVel];
	end
	
	pdAll{idxi} = {subFolders(idxi).name,pd};
end

idx = 1; % use this to separate 3 plots for each subfolder (qinf)
for idxi = 1:numel(subFolders)
	% modified code sample from Narsipur

	% pull out the data for the folder we are working on
	folderName = pdAll{idxi}{1};
	folderName = strrep(folderName,'_',' ');
	folderName = strrep(folderName,'-','.');
	pd = pdAll{idxi}{2};

	% Input the x, y, and z data
	% Here x, y are the respective axis data (in our case the y and z positions of the wake-rake)
	% z corresponds to the data ofor which you want to generate the contour
	x = pd(:,1);
	y = pd(:,2);
	
	% Grid 
	x0 = min(x) ; x1 = max(x) ;
	y0 = min(y) ; y1 = max(y) ;
	N = 75; % How fine you want the disttribution to be
	xl = linspace(x0,x1,N) ; 
	yl = linspace(y0,y1,N) ; 
	[X,Y] = meshgrid(xl,yl) ;

	%-------------------------------------------------
	% plot dynamic pressure distribution
	z = pd(:,3);
	% do inteprolation 
	P = [x,y] ; V = z ;
	F = scatteredInterpolant(P,V) ;
	F.Method = 'natural';
	F.ExtrapolationMethod = 'linear' ;  % none if you dont want to extrapolate
	% Take points lying insuide the region
	pq = [X(:),Y(:)] ; 
	vq = F(pq) ;
	Z = vq ;
	Z = reshape(Z,size(X)) ;

	% Plot
	colormap('jet');
	fig = figure(idx);
	idx = idx + 1;
	hold all;
	contourf(X,Y,Z);
	caxis([min(z) max(z)]);
	h = colorbar;
	ylabel(h, 'Dynamic Pressure (Pa)')
	title(sprintf('Dynamic Pressure Distribution %s',folderName));
	
	saveas(fig,sprintf('labFinal_DynamicPressure_%s.jpg',folderName));
	
	%-------------------------------------------------
	% plot total pressure distribution
	z = pd(:,4);
	% do inteprolation 
	P = [x,y] ; V = z ;
	F = scatteredInterpolant(P,V) ;
	F.Method = 'natural';
	F.ExtrapolationMethod = 'linear' ;  % none if you dont want to extrapolate
	% Take points lying insuide the region
	pq = [X(:),Y(:)] ; 
	vq = F(pq) ;
	Z = vq ;
	Z = reshape(Z,size(X)) ;

	% Plot
	colormap('jet');
	fig = figure(idx);
	idx = idx + 1;
	hold all;
	contourf(X,Y,Z);
	caxis([min(z) max(z)]);
	h = colorbar;
	ylabel(h, 'Total Pressure (Pa)')
	title(sprintf('Total Pressure Distribution %s',folderName));
	
	saveas(fig,sprintf('labFinal_TotalPressure_%s.jpg',folderName));
	
	%-------------------------------------------------
	% plot velocity distribution
	z = pd(:,5);
	% do inteprolation 
	P = [x,y] ; V = z ;
	F = scatteredInterpolant(P,V) ;
	F.Method = 'natural';
	F.ExtrapolationMethod = 'linear' ;  % none if you dont want to extrapolate
	% Take points lying insuide the region
	pq = [X(:),Y(:)] ; 
	vq = F(pq) ;
	Z = vq ;
	Z = reshape(Z,size(X)) ;

	% Plot
	colormap('jet');
	fig = figure(idx);
	idx = idx + 1;
	hold all;
	contourf(X,Y,Z);
	caxis([min(z) max(z)]);
	h = colorbar;
	ylabel(h, 'Velocity (m/s)')
	title(sprintf('Velocity Distribution %s',folderName));

	saveas(fig,sprintf('labFinal_Velocity_%s.jpg',folderName));
	
end

