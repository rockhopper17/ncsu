close all; clear all; clc;

E1 = 30e6;
%E2 = 0.75e6;
E2=E1;
%G12 = 0.375e6;
G12 = 1e6;
%nu12=0.25;
nu12=0;
nu21 = nu12*E2/E1;

theta = 0:90; % in deg
c = cosd(theta);
s = sind(theta);

Ex = 1./((c.^2./E1).*(c.^2-s.^2.*nu12) + (s.^2/E2).*(s.^2-c.^2.*nu21) + (c.^2.*s.^2/G12));
Ey = 1./((s.^2./E1).*(s.^2-c.^2.*nu12) + (c.^2/E2).*(c.^2-s.^2.*nu21) + (c.^2.*s.^2/G12));
Gxy = 1./((4*c.^2.*s.^2/E1).*(1+nu12) + (4*c.^2.*s.^2/E2).*(1+nu21) + (c.^2-s.^2).^2/G12);
nuxy = Ex.*((c.^2./E1).*(c.^2*nu12-s.^2) + (s.^2/E2).*(s.^2*nu21-c.^2) + (c.^2.*s.^2/G12));
etaxs = Ex.*((2*c.^3.*s/E1).*(1+nu12) - (2*c.*s.^3/E2).*(1+nu21) - (c.*s.*(c.^2-s.^2)/G12));
etays = Ex.*((2*c.*s.^3/E1).*(1+nu12) - (2*c.^3.*s/E2).*(1+nu21) + (c.*s.*(c.^2-s.^2)/G12));

plot(theta,Ex,'k-','DisplayName','E_x');
hold on;
plot(theta,Ey,'k--','DisplayName','E_y');
plot(theta,Gxy*100,'k-.','DisplayName','100 G_{xy}');
ylabel('E_x/E_y/G_{xy}');
xlabel('\theta (deg)')
set(gca,'FontSize',14);
legend show;

figure;
plot(theta,nuxy,'k-','DisplayName','\nu_{xy}');
hold on;
plot(theta,etaxs,'k--','DisplayName','\eta_{xs}');
plot(theta,etays,'k-.','DisplayName','\eta_{ys}');
ylabel('\nu_{xy}/\eta_{xs}/\eta_{ys}');
xlabel('\theta (deg)')
set(gca,'FontSize',14);
legend('location','southeast');
