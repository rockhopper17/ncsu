% MAE 451 Lab 1 code, Wednesday lab
% Anna Freundt
% lab: percent turbulance from CTA

% Data file columns: 
% 1 No. of Props | 2 Prop dia (in) | 3 Prop Pitch (in) | 4 Throttle | 5 Q (psf) |...
% 6 V (Volts) | 7 I (Amps) | 8 Thrust (lb) | 9 Torque (in-lb) | 10 RPM | 11 Material (1 - APC; 2- Wood)
rho = 1.18; % kg/m^3 % *3.6127292e-5; % lb/in^3

data = load('Lab-3_prop_data_all_sessions.dat');

j = 1;
k = 1;
prop(j).data = []; prop(j).Num = []; prop(j).D = []; prop(j).Pitch = [];
prop(j).throttle = []; prop(j).q = []; prop(j).V = []; prop(j).I = []; 
prop(j).thrust = []; prop(j).torque = []; prop(j).rpm = []; prop(j).material = []; 
for i = 1:length(data)           % loads in data from folders
%         prop(j).data = [prop(j).data; data(i,:)];
        prop(j).Num(k) = data(i,1);
        prop(j).D(k)= data(i,2)*0.0254;
        prop(j).Pitch(k) = data(i,3)*0.0254;
        prop(j).throttle(k) = data(i,4);
        prop(j).q(k) = data(i,5)*47.88;
        prop(j).V(k) = data(i,6);
        prop(j).I(k) = data(i,7);
        prop(j).thrust(k) = data(i,8)*4.44822;
        prop(j).torque(k) = data(i,9)*0.113;
        prop(j).rpm(k) = data(i,10);
%         prop(j).material(i) = [prop(j).material; data(i,11)]; % 1 - APC; 2- Wood
        
        if  i < length(data)  % changes strucutre index when prop diameter or pitch changes
            if data(i,2) ~= data(i+1,2) || data(i,3) ~= data(i+1,3)
                j = j + 1;
                k = 0;
            end
        end
        k = k + 1;
end
%% Calculations
for i = 1:length(prop)
stuff(i).power = prop(i).V.*prop(i).I;
stuff(i).vInf = sqrt(2.*prop(i).q./rho); % m/s
stuff(i).n = prop(i).rpm/60; % rev/sec
stuff(i).J = stuff(i).vInf ./ (stuff(i).n.*prop(i).D);
stuff(i).Ct = prop(i).thrust ./ (rho*stuff(i).n.^2.*prop(i).D.^4);
stuff(i).Cq = prop(i).torque ./ (rho*stuff(i).n.^2.*prop(i).D.^5)*10;
stuff(i).Cp = stuff(i).power ./ (rho*stuff(i).n.^3.*prop(i).D.^5);
stuff(i).eta = (stuff(i).Ct.*stuff(i).J) ./ (2*pi.*stuff(i).Cq);
stuff(i).eta(prop(i).thrust < 0) = 0;
stuff(i).eta(prop(i).torque < 0) = 0;
end
%% Figures
% Propellor coefficients for each prop
for i = 1:length(stuff)
figure(i)
plot(stuff(i).J,stuff(i).Ct,'sk','LineWidth',2)
hold on
plot(stuff(i).J,stuff(i).Cq,'ob','LineWidth',2)
plot(stuff(i).J,stuff(i).Cp,'>r','LineWidth',2)
plot(stuff(i).J,stuff(i).eta,'pg','LineWidth',2)
titleName = sprintf('Prop diam = %.1f [in]',prop(i).D(i)/0.0254);
title(titleName)
legend('C_T','C_Q','C_P','\eta')
xlabel('J')
ylabel('C_T,C_Q,C_P,\eta')
grid on
end
% Propeller: Ct & Cq > 0
% Air brake: Cq > 0 & Ct < 0 || Cq < 0 & Ct > 0
% Windmill: Ct & Cq < 0

%% Diameter study ( 10x8, 13x8, 15x8, 16x8 )
k1 = [6,5,2,1];
thing1 = {'Ct','Cq','Cp','eta'};
thing1a = {'C_t','C_q','C_p','\eta'};
for i = 1:length(thing1)
figure(i+7)
plot(stuff(6).J,stuff(6).(thing1{i}),'+k','LineWidth',2)
hold on
plot(stuff(5).J,stuff(5).(thing1{i}),'ob','LineWidth',2)
plot(stuff(2).J,stuff(2).(thing1{i}),'sr','LineWidth',2)
plot(stuff(1).J,stuff(1).(thing1{i}),'pg','LineWidth',2)
titleName = sprintf('%s vs J',thing1a{i});
title(titleName)
legend('10x8','13x8','15x8','16x8')
xlabel('J')
ylabel(thing1a{i})
grid on
end
% prop(1) = 16x8
% prop(2) = 15x8
% prop(3) = 10x7
% prop(4) = 10x6
% prop(5) = 13x8
% prop(6) = 10x8
% prop(7) = 10.5x8
%% Pitch ( 10x6, 10x7, 10x8 )
k2 = [4,3,6];
thing1 = {'Ct','Cq','Cp','eta'};
thing1a = {'C_t','C_q','C_p','\eta'};
for i = 1:length(thing1)
figure(i+11)
plot(stuff(4).J,stuff(4).(thing1{i}),'sk','LineWidth',2)
hold on
plot(stuff(3).J,stuff(3).(thing1{i}),'ob','LineWidth',2)
plot(stuff(6).J,stuff(6).(thing1{i}),'>r','LineWidth',2)
titleName = sprintf('%s vs J',thing1a{i});
title(titleName)
legend('10x6','10x7','10x8')
xlabel('J')
ylabel(thing1a{i})
grid on
end
%% Number of Blade ( 10x8, 10.5x8 )
k2 = [6,7];
thing1 = {'Ct','Cq','Cp','eta'};
thing1a = {'C_t','C_q','C_p','\eta'};
for i = 1:length(thing1)
figure(i+15)
plot(stuff(6).J,stuff(6).(thing1{i}),'>r','LineWidth',2)
hold on
plot(stuff(7).J,stuff(7).(thing1{i}),'ob','LineWidth',2)
titleName = sprintf('%s vs J',thing1a{i});
title(titleName)
legend('10x8','10.5x8')
xlabel('J')
ylabel(thing1a{i})
grid on
end