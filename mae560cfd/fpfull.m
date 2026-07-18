close all; clear all; clc;

if 1
%d = readmatrix(['finalprojdata/slndata_init.txt']);
%d = readmatrix(['finalprojdata/slndata_t01.txt']);
%d = readmatrix(['finalprojdata/slndata_t005.txt']);
%nx = 100
%ny = 100

d = readmatrix(['finalprojdata/slndata_lid.txt']);
nx = 128
ny = 128

x = d(:,1); % x cell center
y = d(:,2); % y cell center
u = d(:,3); % u vel
v = d(:,4); % v vel
p = d(:,5); % p pressure
vel = d(:,6); % vel mag
%vel = sqrt(u.^2 + v.^2);

%xv = linspace(min(x), max(x), 100);
%yv = linspace(min(y), max(y), 100);
%[X,Y] = meshgrid(xv, yv);
%Z = griddata(x,y,u,X,Y);

x = reshape(x,[nx,ny]);
y = reshape(y,[nx,ny]);
u = reshape(u,[nx,ny]);
u(64,8)

colormap jet
%z = reshape(u,[nx,ny]);
z = reshape(vel,[nx,ny]);
contourf(x,y,z,16);
xlabel('x');
ylabel('y');
c = colorbar;
%c.Label.String = 'u vel';
c.Label.String = 'vel mag';
set(gca,'FontSize',16);
set(gcf,'Position',[500, 500, 1000, 800]);

%figure;
%colormap jet
%z = reshape(p,[nx,ny]);
%contourf(x,y,z,16);
%xlabel('x');
%ylabel('y');
%c = colorbar;
%c.Label.String = 'pressure';
%set(gca,'FontSize',16);
%set(gcf,'Position',[500, 500, 1000, 800]);

end
%=========================================================
if 0

d = readmatrix(['finalprojdata/evodata_Re10.txt']);
t = d(:,1);
veldiv10 = d(:,2);
kindec10 = d(:,3);
d = readmatrix(['finalprojdata/evodata_Re100.txt']);
veldiv100 = d(:,2);
kindec100 = d(:,3);
d = readmatrix(['finalprojdata/evodata_Re1000.txt']);
veldiv1000 = d(:,2);
kindec1000 = d(:,3);

plot(t,kindec10,'k','DisplayName','Re=10');
hold on; grid on;
plot(t,kindec100,'b','DisplayName','Re=100');
plot(t,kindec1000,'r','DisplayName','Re=1000');
xlabel('time (s)');
ylabel('total kinetic energy');
ylim([0 0.3]);
set(gca,'FontSize',16);
legend('location','southwest');

end
