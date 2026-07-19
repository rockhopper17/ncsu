clear;
clc;
close all;

for f = 500000:10000:800000
%f=300000;     % Lamb wave frequency
T=1/f;
i=0;
time = double.empty(0);
y = double.empty(0);

%%
for t=0:0.05e-6:(1/f)*5.5
    i=i+1;
    time(i,1)=t;
    
    y(i,1)=(heaviside(t)-heaviside(t-5.5*T))*((1/2)*(1-cos(2*pi*f*t/5.5))*(sin(2*pi*f*t)));  %Islam 2016

end
  
figure('units','normalized','outerposition',[0 0 1 1])
fig2=plot(time*1000000,y(:,1),'b-','LineWidth',2)
xlabel('time (\mus)', 'FontSize', 80)
ylabel('voltage (V)', 'FontSize', 80)
set(fig2,'LineWidth',7)
set(gca,'LineWidth',5)
set(gca,'FontSize',80)
axis([0 max(time*1000000) -1.5 1.5])
    
%%
  convertToArb(y,i/time(i,1),sprintf('HNFN_%04d',f*1e-3))

end % end loop of frequencies
