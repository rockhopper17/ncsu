%% Pseudocode for Contour Plots
% Input the x, y, and z data
% Here x, y are the respective axis data (in our case the y and z positions of the wake-rake)
% z corresponds to the data ofor which you want to generate the contour
x = pd(:,1) ;
y = pd(:,2) ;
z = pd(:,4);
% Grid 
x0 = min(x) ; x1 = max(x) ;
y0 = min(y) ; y1 = max(y) ;
N = 75; % How fine you want the disttribution to be
xl = linspace(x0,x1,N) ; 
yl = linspace(y0,y1,N) ; 
[X,Y] = meshgrid(xl,yl) ;

%% do inteprolation 
P = [x,y] ; V = z ;
F = scatteredInterpolant(P,V) ;
F.Method = 'natural';
F.ExtrapolationMethod = 'linear' ;  % none if you dont want to extrapolate
% Take points lying insuide the region
pq = [X(:),Y(:)] ; 
vq = F(pq) ;
Z = vq ;
Z = reshape(Z,size(X)) ;

%% Plot
figure(1)
hold all
contourf(X,Y,Z)
caxis([min(pd(:,4)) max(pd(:,4))]);
h = colorbar
ylabel(h, 'Contour Axis Label')
title('Plot/Image Title')