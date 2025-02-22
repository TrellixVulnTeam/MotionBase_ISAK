close all
clear
clc

%% Define dimensions
r_base = 0.402;             % radius of platform, in m
r_platform = 0.265;         % radius of base, in m
shortleg = 0.16;            % length of motor arm, in m
longleg = 1;                % length of connecting rod, in m
z0_platform = 1.1;          % rest height of platform
m = 340/2.2;                % mass of platform   (from Inventor model)
J = [15.63, 35.35, 40.50];  % inertia, kg-m^2    (from Inventor model)
hex_angles = [-pi/6:pi/3:9*pi/6]; % establish motor positions on base
motor_yaws = [270, 90, 30, 210, 150, 330]*pi/180;

%% Read in raw data
rawdata=csvread('2015-01-24_11-49-26.csv');   % roundabout data file
time1 = rawdata(:,2);

% actual angle, called "MotionRoll/Pitch/Yaw" in data --> checked by
%   inspection of plot_roundabout_data.m
%   --> raw values in radians
angle_x=rawdata(:,26);  %CHECK THESE COLUMN ORDERS!!!
angle_y=rawdata(:,25);
angle_z=rawdata(:,24);
yaw_index = find(diff(angle_z) > 100*pi/180);  %find where rollover in yaw occurs
yaw_adjust = angle_z(yaw_index:end) - 360*pi/180;   %adjust yaw after rollover by 360 degrees
angle_z = [angle_z(1:yaw_index-1); yaw_adjust];
angle=[angle_x, angle_y, angle_z];

% linear acceleration, called "AccelerationX/Y/Z" in data
%   --> raw values in g's, want to convert to m/s^2
acc_x=rawdata(:,13).*9.81;
acc_y=rawdata(:,12).*9.81;%THESE DIRECTIONS ARE OUT OF ORDER. WEIRD
acc_z=rawdata(:,14).*9.81;%NOW THESE ARE IN M/S/S SO MAKE SURE SIM IS TOO!
accel=[acc_x, acc_y, acc_z+9.81];%added g to z to offset gravity. This is meh....

% compose signals for simulink
signal_x=[time1,accel(:,1)];
signal_y=[time1,accel(:,2)];
signal_z=[time1,accel(:,3)];
signal_yaw = [time1,angle_z];

% figure()
% subplot(3,1,1)
% plot(signal_x(:,1),signal_x(:,2))
% ylabel('ax')
% subplot(3,1,2)
% plot(signal_y(:,1),signal_y(:,2))
% ylabel('ay')
% subplot(3,1,3)
% plot(signal_z(:,1),signal_z(:,2))
% xlabel('Time (s)')
% ylabel('az')
% 
% pause 

%% Run simulink motion cueing algorithm
%   --> output is axtilt, aytilt, xdesired, ydesired, zdesired
sim('demostration1.slx');
motion_des = [xdesired, ydesired, zdesired];
angle_x = interp1(time1, angle(:,1), simtime);
angle_y = interp1(time1, angle(:,2), simtime);
angle_z = interp1(time1, angle(:,3), simtime);
angle_des = [angle_x+axtilt, angle_y+aytilt, anglez];   %% had to do stupid things to trim vectors, should fix this later -->FIXED

%% Calculate linear velocity, acceleration and angular velocity, acceleration    
vel_desX(:,1) = [0; diff(motion_des(:,1))./diff(simtime)];      % split into XYZ to make sure diff works in the right direction
vel_desY(:,2) = [0; diff(motion_des(:,2))./diff(simtime)];
vel_desZ(:,3) = [0; diff(motion_des(:,3))./diff(simtime)];

acc_desX(:,1) = [0; diff(vel_desX)./diff(simtime)];
acc_desY(:,2) = [0; diff(vel_desY(:,2))./diff(simtime)];
acc_desZ(:,3) = [0; diff(vel_desZ(:,3))./diff(simtime)];

omega_desX(:,1) = [0; diff(angle_des(:,1))./diff(simtime)];
omega_desY(:,2) = [0; diff(angle_des(:,2))./diff(simtime)];
omega_desZ(:,3) = [0; diff(angle_des(:,3))./diff(simtime)];

alpha_desX(:,1) = [0; diff(omega_desX)./diff(simtime)];
alpha_desY(:,2) = [0; diff(omega_desY(:,2))./diff(simtime)];
alpha_desZ(:,3) = [0; diff(omega_desZ(:,3))./diff(simtime)];
    
vel_des = [vel_desX, vel_desY(:,2), vel_desZ(:,3)];   % compose into nice matrices
acc_des = [acc_desX, acc_desY(:,2), acc_desZ(:,3)];
omega_des = [omega_desX, omega_desY(:,2), omega_desZ(:,3)];
alpha_des = [alpha_desX, alpha_desY(:,2), alpha_desZ(:,3)];

%% Plot desired velocities, accelerations, both angular and linear
% figure()
% subplot(2,2,1)
% hold on
% plot(simtime,vel_desX)
% plot(simtime,vel_desY)
% plot(simtime,vel_desY)
% xlabel 'time'
% ylabel 'desired velocity'
% legend('X', 'Y', 'Z')
% hold off
% subplot(2,2,2)
% hold on
% plot(simtime,acc_desX)
% plot(simtime,acc_desY)
% plot(simtime,acc_desZ)
% xlabel 'time'
% ylabel 'desired acceleration'
% legend('X', 'Y', 'Z')
% hold off
% subplot(2,2,3)
% hold on
% plot(simtime,omega_desX)
% plot(simtime,omega_desY)
% plot(simtime,omega_desZ)
% xlabel 'time'
% ylabel 'desired angular velocity'
% legend('X', 'Y', 'Z')
% hold off
% subplot(2,2,4)
% hold on
% plot(simtime,alpha_desX)
% plot(simtime,alpha_desY)
% plot(simtime,alpha_desZ)
% xlabel 'time' 
% ylabel 'desired angular acceleration'
% legend('X', 'Y', 'Z')
% hold off
% 
% pause

%% Plot desired acc vs. acc data
% figure()
% hold on
% plot(time1,accel)
% plot(simtime,acc_des)
% hold off
% xlabel 'time'
% ylabel 'accel'
% legend()

%% Plot the desired angles, motions
% figure()
% plot(simtime,angle_des(:,1),simtime,angle_des(:,2),simtime,angle_des(:,3))
% xlabel('Time (s)')
% ylabel('Desired angles')
% legend('x','y','z')
% 
% figure()
% plot(simtime,motion_des(:,1),simtime,motion_des(:,2),simtime,motion_des(:,3))
% xlabel('Time (s)')
% ylabel('Desired motion')
% legend('x','y','z')
% 
% pause

%% Run loop to determine platform position, motor arm angles, motor torques
% notation:
%       P = connection point between connecting rod and platform
%       Q = connection point between motor arm and connecting rod
%       O = connection point between motor arm and base
%       G = 0,0,0 (ground)
R_po = zeros(6,3);
R_pq = zeros(6,3);
R_qo = zeros(6,3);
F_pq = zeros(6,3);
initial = 0;
opt_theta = zeros(6,1);
error = zeros(6,1);
T = zeros(6,1);
T_qo = zeros(6,3);
Rpq_x = zeros(6,1);
Rpq_y = zeros(6,1);
Rpq_z = zeros(6,1);
Rqo_x = zeros(6,1);
Rqo_y = zeros(6,1);
Rqo_z = zeros(6,1);
T_qo_x = zeros(6,1);
T_qo_y = zeros(6,1);
T_qo_z = zeros(6,1);
Motor_Torques = zeros(length(simtime),6);

for i=1:length(motion_des)    % motion index
    % solve for platform position and R_po
    [R_po, motors, R_pg, motorangles, R_pc] = platformposition(hex_angles, motion_des(i,:),angle_des(i,:), r_base, r_platform, z0_platform);

    % angle bisection method
    for j = 1:6     % leg index
        theta_max = pi/2;
        theta_min = 0;
        tol = 0.0001;
        error = 100000;
        theta = theta_min;
        iter = 0;
        maxiter = 20;
        
        while (abs(error) > tol && iter<maxiter)
            iter = iter+1;
            [error, Rpq_x, Rpq_y, Rpq_z] = findRpq(R_po(j,:), shortleg, longleg, motor_yaws(j), theta);
            R_pq = [Rpq_x, Rpq_y, Rpq_z];
            
            if error < 0
                theta_min = theta;
            else
                theta_max = theta;
            end
            
            if abs(error) > tol
                theta = theta_min + (theta_max-theta_min)/2;
                if iter==20
                    opt_theta(i,j) = theta;
                    R_qo = R_po(j,:) - R_pq;
                    Rpq_vecX(j,1) = R_pq(1);     % had to disassemble vectors
                    Rpq_vecY(j,1) = R_pq(2);
                    Rpq_vecZ(j,1) = R_pq(3);
                    Rqo_vecX(j,1) = R_qo(1);
                    Rqo_vecY(j,1) = R_qo(2);
                    Rqo_vecZ(j,1) = R_qo(3);
      
                end
            else
                opt_theta(i,j) = theta;
                R_qo = R_po(j,:) - R_pq;
                Rpq_vecX(j,1) = R_pq(1);     % had to disassemble to turn into vectors
                Rpq_vecY(j,1) = R_pq(2);
                Rpq_vecZ(j,1) = R_pq(3);
                Rqo_vecX(j,1) = R_qo(1);
                Rqo_vecY(j,1) = R_qo(2);
                Rqo_vecZ(j,1) = R_qo(3);
            end
        end 
    end
    
        R_pq = [Rpq_vecX, Rpq_vecY, Rpq_vecZ];       % reassemble
        R_qo = [Rqo_vecX, Rqo_vecY, Rqo_vecZ];
    
    % find force, torque on each leg
    for k = 1:6
        [F_pq] = forceplatform(m, J, R_pq(1,:), R_pq(2,:), R_pq(3,:), R_pq(4,:), R_pq(5,:), R_pq(6,:), R_pc(1,:), R_pc(2,:), R_pc(3,:), acc_des(i,:), alpha_des(i,:));
        
        for index_m = 1:6
            T_qo = cross(R_qo(index_m,:), -F_pq(index_m,:));
            T_qo_x(index_m) = T_qo(1);     % had to disassemble R_pq so that it would write to j
            T_qo_y(index_m) = T_qo(2);
            T_qo_z(index_m) = T_qo(3);
        end
        
        T_qo = [T_qo_x, T_qo_y, T_qo_z];    % reassemble
                
        e_motorX = cos(motor_yaws');
        e_motorY = sin(motor_yaws');
        e_motorZ = zeros(size(e_motorX));
        e_motor = [e_motorX, e_motorY, e_motorZ];   % unit vectors for motors
        Motor_Torques(i,k) = dot(e_motor(k,:), T_qo(k,:));      % calculate torque in the direction of the motor
    end
    
    
        % just for plotting
            cla()

    hold on
    grid on
    platformX = [R_pg(1,1),R_pg(2,1),R_pg(3,1),R_pg(1,1)];
    platformY = [R_pg(1,2),R_pg(2,2),R_pg(3,2),R_pg(1,2)];
    platformZ = [R_pg(1,3),R_pg(2,3),R_pg(3,3),R_pg(1,3)];
    baseX = [motors(1,1),motors(2,1),motors(3,1),motors(4,1),motors(5,1),motors(6,1),motors(1,1)];
    baseY = [motors(1,2),motors(2,2),motors(3,2),motors(4,2),motors(5,2),motors(6,2),motors(1,2)];
    baseZ = [motors(1,3),motors(2,3),motors(3,3),motors(4,3),motors(5,3),motors(6,3),motors(1,3)];
        
    motorarm1X = [motors(1,1), R_qo(1,1)+motors(1,1)];
    motorarm2X = [motors(2,1), R_qo(2,1)+motors(2,1)];
    motorarm3X = [motors(3,1), R_qo(3,1)+motors(3,1)];
    motorarm4X = [motors(4,1), R_qo(4,1)+motors(4,1)];
    motorarm5X = [motors(5,1), R_qo(5,1)+motors(5,1)];
    motorarm6X = [motors(6,1), R_qo(6,1)+motors(6,1)];
    
    motorarm1Y = [motors(1,2), R_qo(1,2)+motors(1,2)];
    motorarm2Y = [motors(2,2), R_qo(2,2)+motors(2,2)];
    motorarm3Y = [motors(3,2), R_qo(3,2)+motors(3,2)];
    motorarm4Y = [motors(4,2), R_qo(4,2)+motors(4,2)];
    motorarm5Y = [motors(5,2), R_qo(5,2)+motors(5,2)];
    motorarm6Y = [motors(6,2), R_qo(6,2)+motors(6,2)];
    
    motorarm1Z = [motors(1,3), R_qo(1,3)+motors(1,3)];
    motorarm2Z = [motors(2,3), R_qo(2,3)+motors(2,3)];
    motorarm3Z = [motors(3,3), R_qo(3,3)+motors(3,3)];
    motorarm4Z = [motors(4,3), R_qo(4,3)+motors(4,3)];
    motorarm5Z = [motors(5,3), R_qo(5,3)+motors(5,3)];
    motorarm6Z = [motors(6,3), R_qo(6,3)+motors(6,3)];

    conrod1X = [R_pg(1,1), R_pg(1,1)-R_pq(1,1)];
    conrod2X = [R_pg(1,1), R_pg(1,1)-R_pq(2,1)];
    conrod3X = [R_pg(2,1), R_pg(2,1)-R_pq(3,1)];
    conrod4X = [R_pg(2,1), R_pg(2,1)-R_pq(4,1)];
    conrod5X = [R_pg(3,1), R_pg(3,1)-R_pq(5,1)];
    conrod6X = [R_pg(3,1), R_pg(3,1)-R_pq(6,1)];
  
    conrod1Y = [R_pg(1,2), R_pg(1,2)-R_pq(1,2)];
    conrod2Y = [R_pg(1,2), R_pg(1,2)-R_pq(2,2)];
    conrod3Y = [R_pg(2,2), R_pg(2,2)-R_pq(3,2)];
    conrod4Y = [R_pg(2,2), R_pg(2,2)-R_pq(4,2)];
    conrod5Y = [R_pg(3,2), R_pg(3,2)-R_pq(5,2)];
    conrod6Y = [R_pg(3,2), R_pg(3,2)-R_pq(6,2)];
    
    conrod1Z = [R_pg(1,3), R_pg(1,3)-R_pq(1,3)];
    conrod2Z = [R_pg(1,3), R_pg(1,3)-R_pq(2,3)];
    conrod3Z = [R_pg(2,3), R_pg(2,3)-R_pq(3,3)];
    conrod4Z = [R_pg(2,3), R_pg(2,3)-R_pq(4,3)];
    conrod5Z = [R_pg(3,3), R_pg(3,3)-R_pq(5,3)];
    conrod6Z = [R_pg(3,3), R_pg(3,3)-R_pq(6,3)];
    
    plot3(motorarm1X, motorarm1Y, motorarm1Z, 'LineWidth', 3);
    plot3(motorarm2X, motorarm2Y, motorarm2Z, 'LineWidth', 3);
    plot3(motorarm3X, motorarm3Y, motorarm3Z, 'LineWidth', 3);
    plot3(motorarm4X, motorarm4Y, motorarm4Z, 'LineWidth', 3);
    plot3(motorarm5X, motorarm5Y, motorarm5Z, 'LineWidth', 3);
    plot3(motorarm6X, motorarm6Y, motorarm6Z, 'LineWidth', 3);
    plot3(conrod1X, conrod1Y, conrod1Z, 'LineWidth', 3);
    plot3(conrod2X, conrod2Y, conrod2Z, 'LineWidth', 3);
    plot3(conrod3X, conrod3Y, conrod3Z, 'LineWidth', 3);
    plot3(conrod4X, conrod4Y, conrod4Z, 'LineWidth', 3);
    plot3(conrod5X, conrod5Y, conrod5Z, 'LineWidth', 3);
    plot3(conrod6X, conrod6Y, conrod6Z, 'LineWidth', 3);
    patch(platformX, platformY, platformZ, 'b');
    patch(baseX, baseY, baseZ, 'r')
    view(-205,45)
    pause(0.00001)
    zlim([-0.5 1.5])
    xlim([-0.75 0.5])
    ylim([-0.75 0.5])
    
    % create .gif
    filename = 'simMotion.gif';
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if i == 1;
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
    
end
hold off

%% calculate angular velocity
omega = zeros(size(Motor_Torques));

for n = 1:6     % leg index
    opt_new = opt_theta(:,n);  % split angle matrix into columns
    for i=1:length(opt_new)  % motion index
        if i>1
            omega(i,n)= (opt_new(i)-opt_new(i-1))/(simtime(i)-simtime(i-1));
        else
            omega(i,n) = 0;
        end
    end
end

%% plot motor angles
figure()
plot(simtime,opt_theta(:,1),simtime,opt_theta(:,2),simtime,opt_theta(:,3),simtime,opt_theta(:,4),simtime,opt_theta(:,5),simtime,opt_theta(:,6))
hold on
plot([min(simtime) max(simtime)],[0,0],'r','LineWidth',4)
plot([min(simtime) max(simtime)],[pi/2,pi/2],'r','LineWidth',4)
legend('motor 1','motor 2','motor 3','motor 4','motor 5','motor 6','motor limits')
xlabel('Time (s)')
ylabel('motor arm angle requested (rad)')

%% finally plot the torque-omega curve!!
om = medfilt1(omega,3);
torque = medfilt1(Motor_Torques,3);    % filter data a little bit

figure()
hold on
plot(abs(om),torque, '.')
xlim([0, 2])
ylim([0, 150])
xlabel 'Omega (rad/s)'
ylabel 'Torque (N-m)'
hold off



