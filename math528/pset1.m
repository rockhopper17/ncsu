% problem set 1 ODEs

% book 1.2 #2
% y' = -4x/y  pts (1,1),(0,2)
%[x,y] = meshgrid(-.4:.2:1.4,[-1:.2:-.2 .2:.2:3]);
%dy = -4.*x./y;
%dx = ones(size(dy));
%quiver(x,y,dx,dy);

% book 1.2 #3
% y' = 1-y^2 pts (0,0),(2,.5)
[x,y] = meshgrid(-1:.2:2,-2:.1:2);
dy = 1-y.^2;
dx = ones(size(dy));
quiver(x,y,dx,dy);

