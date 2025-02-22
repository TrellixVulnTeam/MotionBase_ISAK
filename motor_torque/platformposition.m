function [Length, Base, Platform, hex_angles, R_pc] = platformposition(hex_angles, motion_desired, angle_desired, r_base, r_platform, initial_platform_height)
%traj(xdesired(i),ydesired(i),1+zdesired(i),anglex(i)+axtilt(i),angley(i)+aytilt(i),anglez(i)); 
% Computes distance from motor shaft to connection point on top platform
%       Inputs:     motion_desired   vector(x,y,z) of the desired lateral motion
%                   angle_desired    vector(x,y,z) of the desired acceleration
%       Outputs:    L                matrix of vectors for legs 1-6
%                   length           matrix of length magnitudes
%                   Base             xyz location of base points
%                   Platform         xyz location of platform points

tri_angles = [0,2*pi/3,4*pi/3];

Bx = r_base.*cos(hex_angles);
By = r_base.*sin(hex_angles);
Bz = zeros(size(hex_angles));
B = [Bx; By; Bz];
Base = B';

Tx = r_platform.*cos(tri_angles);
Ty = r_platform.*sin(tri_angles);
Tz = zeros(size(tri_angles));       % these are local coordinates
platformLocal = [Tx; Ty; Tz];

% get ready for platform movement
motion=[motion_desired(1); motion_desired(2); motion_desired(3)]; 
R_cg = [motion_desired(1), motion_desired(2), motion_desired(3) + initial_platform_height]; 
R_cg = ones(3,1)*R_cg;

% points on platform, not yet rotated
T1 = [Tx(1); Ty(1); Tz(1)];
T2 = [Tx(2); Ty(2); Tz(2)];
T3 = [Tx(3); Ty(3); Tz(3)];

% rotation matrices
Rx=[1 0 0; 0 cos(angle_desired(1)) -sin(angle_desired(1)); 0 sin(angle_desired(1)) cos(angle_desired(1))];
Ry=[cos(angle_desired(2)) 0 sin(angle_desired(2)); 0 1 0; -sin(angle_desired(2)) 0 cos(angle_desired(2))];
Rz=[cos(angle_desired(3)) -sin(angle_desired(3)) 0; sin(angle_desired(3)) cos(angle_desired(3)) 0; 0 0 1];

% rotate the top vectors using rotation matrices, z y x order because yaw
%   angle will probably be the largest
T1=Rz*T1;
T1=Ry*T1;
T1=Rx*T1;

T2=Rz*T2;
T2=Ry*T2;
T2=Rx*T2;

T3=Rz*T3;
T3=Ry*T3;
T3=Rx*T3;

% re-establish points on platform w/global coordinates
p1_x = T1(1) + motion(1);
p1_y = T1(2) + motion(2);
p1_z = T1(3) + motion(3) + initial_platform_height;

p2_x = T2(1) + motion(1);
p2_y = T2(2) + motion(2);
p2_z = T2(3) + motion(3) + initial_platform_height;

p3_x = T3(1) + motion(1);
p3_y = T3(2) + motion(2);
p3_z = T3(3) + motion(3) + initial_platform_height;

Platform = [p1_x, p1_y, p1_z; p2_x, p2_y, p2_z; p3_x, p3_y, p3_z]; % R_p/g
R_pc = Platform - R_cg;  % has been fixed

% compute vector from motor shaft to triangle points
L1 = Platform(1,:)-Base(1,:);
L2 = Platform(1,:)-Base(2,:);
L3 = Platform(2,:)-Base(3,:);
L4 = Platform(2,:)-Base(4,:);
L5 = Platform(3,:)-Base(5,:);
L6 = Platform(3,:)-Base(6,:);
Length = [L1; L2; L3; L4; L5; L6];


% % plot
% platformX = [p1_x, p2_x, p3_x, p1_x];
% platformY = [p1_y, p2_y, p3_y, p1_y];
% platformZ = [p1_z, p2_z, p3_z, p1_z];
% baseX = [Bx, Bx(1)];
% baseY = [By, By(1)];
% baseZ = [Bz, Bz(1)];
% makefig = figure();
% hold on
% plot3(platformX, platformY, platformZ)
% plot3(baseX, baseY, baseZ)
% view(-205,45)
% grid on


end

