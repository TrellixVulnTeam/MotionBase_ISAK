function [F_pq] = forceplatform(m, J, Rpq1, Rpq2, Rpq3, Rpq4, Rpq5, Rpq6, r1, r2, r3,  acc, theta)
%inputs:
%   for point r(i) on top platform:
%                    Rpq(i)=(x,y,z)      vector of the arm
%                       
%   requests:        acc=(x,y,z)         acceleration vector
%                    theta=(x,y,z)       angle
%                       
%   properties:      m                   mass
%                    J                   inertia
%

e1 = Rpq1/norm(Rpq1);
e2 = Rpq2/norm(Rpq2);
e3 = Rpq3/norm(Rpq3);
e4 = Rpq4/norm(Rpq4);
e5 = Rpq5/norm(Rpq5);
e6 = Rpq6/norm(Rpq6);       % e is the unit vector in the direction of the force

M1 = cross(r1, e1);
M2 = cross(r1, e2);
M3 = cross(r2, e3);
M4 = cross(r2, e4);
M5 = cross(r3, e5);
M6 = cross(r3, e6);       % M is the unit vector giving the direction of the moment

A = [e1(1), e2(1), e3(1), e4(1), e5(1), e6(1);
    e1(2), e2(2), e3(2), e4(2), e5(2), e6(2);
    e1(3), e2(3), e3(3), e4(3), e5(3), e6(3);
    M1(1), M2(1), M3(1), M4(1), M5(1), M6(1); 
    M1(2), M2(2), M3(2), M4(2), M5(2), M6(2); 
    M1(3), M2(3), M3(3), M4(3), M5(3), M6(3)];

b = [m*acc(1);
    m*acc(2);
    m*(acc(3)+9.8);
    J(1)*theta(1);
    J(2)*theta(2);
    J(3)*theta(3)];

F = inv(A)*b;

F1 = F(1)*e1;
F2 = F(2)*e2;
F3 = F(3)*e3;
F4 = F(4)*e4;
F5 = F(5)*e5;
F6 = F(6)*e6;       % solve for force vectors

F_pq = [F1; F2; F3; F4; F5; F6];        % compose matrix to send back to main code

end