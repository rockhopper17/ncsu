
%-------------------------------------------------------------------------
%---Simple pendulum using Euler-Cromer Numerical Method------------------
%------------------------------------------------------------------------
clc;
clear all;
close all;
L= 1;  % Length of Pendulum
g=9.8; % Gravity 
M=1; % mass
N=300;  % Maximum number of time steps
dt=0.01;  % Step size for time
w(1:N)=0;  % Angular velocity array
Theta(1:N)=0;  % Angular coordinate array
t(1:N)=0;   % Time array
Theta(1)=0.5; % Initial position of pendulum
for i=1:N-1
    w(i+1)=w(i)-(g/L)*Theta(i)*dt;
    Theta(i+1)=Theta(i)+w(i+1)*dt;
    X(i)=L*sin(Theta(i)); % polar to cartesian
    Y(i)=-L*cos(Theta(i));
    t(i+1)=t(i)+dt;
end
 %-----------------------------------------------------------------------
 %---Energy Calculations-------------------------------------------------
 %----------------------------------------------------------------------
  X(N)=L*sin(Theta(N)); 
  Y(N)=-L*cos(Theta(N));
  T=0.5*M*(L^2)*(w.^2); % Kinetic energy (T)
  T=T/max(T); % normalized potential energy (V)
  V=(M*g*Y)+g; % potential energy (V)
  V=V/max(V); % normalized potential energy (V)
  E=T+V; % total normalized energy (E)
 
% plotting/animation of results
  
for i=1:N
    figure(1)
    subplot(121)
    plot(X(i),Y(i),'.','markersize',65); 
    axis([-0.5 0.5  -1.05 0]);
    line([0 X(i)], [0 Y(i)],'Linewidth',2);
    xlabel('X '); 
    ylabel('Y'); 
    titlestring = ['pendulum motion at t =',num2str(i*dt), 'seconds'];
    title(titlestring ,'fontsize',14);                            
    h=gca; 
    get(h,'FontSize') ;
    set(h,'FontSize',14);
    fh = figure(1);
    set(fh, 'color', 'white'); 
    
    subplot(122)
    plot(t(i),T(i),'.','markersize',15)
    hold on
    plot(t(i),V(i),'.','markersize',15,'MarkerEdgeColor','r')
    hold on 
    plot(t(i),T(i)+V(i),'.','markersize',15,'MarkerEdgeColor','k')
    
    line([2.3 2.7], [0.6 0.6],'color','r','Linewidth',2)
    text(2.4,0.63,'V','fontSize',12)
    line([2.3 2.7], [0.5 0.5],'color','b','Linewidth',2)
    text(2.4,0.53,'T','fontSize',12)
    line([2.3 2.7], [0.4 0.4],'color','k','Linewidth',2)
    text(2.4,0.43,'E','fontSize',12)
    
    title('Energy vs time' ,'fontsize',14);  
    xlabel('time ','fontsize',14); 
    ylabel('energy','fontsize',14); 
    axis([ 0 3 0 1.1])
    h=gca; 
    get(h,'FontSize') ;
    set(h,'FontSize',14);
    fh = figure(1);
    set(fh, 'color', 'white');  
    Yr=getframe;
end
 
 movie(Yr)
%.........................................................................
    
    
 
