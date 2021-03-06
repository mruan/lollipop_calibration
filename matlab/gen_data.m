function [] = gen_data()

c = [0 0 0 1 0 0 0; ...
     2 0 3 cos(-pi/4) 0 sin(-pi/4) 0]; % offset by 1-x and look backwards

b = [ 1.0 0.0  1.0;...
     -1.0 0.0  2.0;...
      0.0 1.0  1.0]';
     

nsr = 0.02;
n   = 100;
r   = 0.1275;

fd = fopen('out.txt', 'w');

[num_c, ~] = size(c);
[~, num_b] = size(b);
fprintf(fd, '%d %d %d\n', num_c, num_b, n);

for i=1:num_c
    fprintf(fd, '%f %f %f %f %f %f %f\n',c(i,1),c(i,2),c(i,3),c(i,4),c(i,5),c(i,6),c(i,7));
end
for i=1:num_b
    fprintf(fd, '%f %f %f\n', b(1,i), b(2, i), b(3,i));
end

hdl = {'.r', '.g'};
figure(1); clf; hold on;
for i=1:num_c

   for j=1:num_b
       p = gen_points(c(i,:), b(:,j), n, nsr, r);
     
       for k=1:n
          fprintf(fd, '%f %f %f\n', p(1,k), p(2,k), p(3,k)); 
       end
       
       P = proj_points(c(i,:), p);
       plot3(P(1,:), P(2,:), P(3,:), hdl{i});
       plot3([c(i,1), b(1,j)], [c(i,2), b(2,j)], [c(i,3), b(3,j)]);
   end
end
hold off; axis equal
fclose(fd);
%plot3(p00(1,:), p00(2,:), p00(3,:), 'b.', p01(1,:), p01(2,:), p01(3,:), 'r.');
%axis equal
end

function [P] = proj_points(c, p)
t = c(1:3)';
R = q2r(c(4:7));

[~, n] = size(p);
P = R*p + repmat(t, 1, n);
end

function [P] = gen_points(c, b, n, nsr, r)


% transform center in world frame to camera frame
R   = q2r([c(4) -c(5:7)]);
b_c = R*(b- c(1:3)');

fprintf('%f %f %f\n', b_c(1), b_c(2), b_c(3));
% 
d = norm(b_c);

c_rd = acos(r/d);

theta = 2*pi*rand([1,n]);  % 0 - 2pi
phi   = (pi-c_rd) + c_rd*rand([1,n]);
noise = nsr * randn([1,n]);

z = (d + r*cos(phi)).*(1+noise);
x = r*sin(phi).*sin(theta).*(1+noise);
y = r*sin(phi).*cos(theta).*(1+noise);

% rotate the points to the correct direction
zp = b_c/d;
yp = cross([0 0 1], zp)'; yp = yp/norm(yp);
xp = cross(yp, zp);
R  = [xp, yp, zp];

P = R*[x; y; z];
end