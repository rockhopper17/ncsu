clear all

%% Define the initial and final states of the time vector

t_initial = 0;
t_final = 2*3600;
Radius_Earth = 6378

%% Using the problem statement, define intiial position and velocity vectors

r0 = [3207; 5459; 2714];
v0 = [-6.532; 0.7835; 6.142];

init_cond = [r0;v0];    % Set as initial conditions

[t,r] = ode45('hw2p1states',[t_initial t_final], init_cond);

%% Part a answer
[m,n] = size(t);
for i = 1:m
    pos_mag(i,1) = sqrt(r(i,1)^2+r(i,2)^2+r(i,3)^2);
    vel_mag(i,1) = sqrt(r(i,4)^2+r(i,5)^2+r(i,6)^2);
end
position_vector_as_func_t = [pos_mag t];
[max_value,I] = max(position_vector_as_func_t(:,1));
maximum_position = max_value-Radius_Earth
time_of_max_position = t(I)

figure
plot(t,pos_mag)
xlabel('Time (sec)')
ylabel('Magnitude of position (km)')
figure
plot(t,vel_mag)
xlabel('Time (sec)')
ylabel('Magnitude of velocity (km/s)')

%% Part b answer

final_pos = [r(end,1) r(end,2) r(end,3)]
final_velocity = [r(end,4) r(end,5) r(end,6)]





