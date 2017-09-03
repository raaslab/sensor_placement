clear all;
clc;

x = 0:0.1:4;
y = x;
[X, Y] = meshgrid(x);

obj = zeros(size(X,1));
for i = 1 : size(X, 1)
	for j = 1 : size(X, 1)
		obj(i, j) = actual_values(X(i, j), Y(i, j), 4, 4);  
	end
end

surf(X, Y, obj);
% axis equal;