nx = 25;
ny = 25;
nz = 25;

x1 = linspace(-3,3,25); x2 = linspace(-3,3,25);
[X1,X2] = meshgrid(x1,x2);

z1 = X1.^2 + X2.^2 + rand(25);
z2 = X1.^2 + X2.^2 + 3 + rand(25);
%surf(x,y,z1);
%hold on
%surf(x,y,z2)
%% Create 3D grid containing distance to closest surface
surf(X1,X2,z2-z1-1);
hold on;
[y3,x3,z3] = ndgrid(linspace(-2,2,ny),linspace(-2,2,nx),linspace(-10,15,nz));
v = zeros(size(z3));
for r=1:ny
    for c=1:nx
        for s=1:nz
            d1 = z3(r,c,s) - z1(r,c);
            d2 = z2(r,c) - z3(r,c,s);
            if d1 < 0
                v3(r,c,s) = d1;
            elseif d2 < 0
                v3(r,c,s) = d2;
            else
                v3(r,c,s) = min(d1,d2);
            end
        end
    end
end
%% Create isosurface
figure
grid on;
p = [patch(isosurface(x3,y3,z3,v3,0)), ...
     patch(isocaps(x3,y3,z3,v3,0))];
isonormals(x3,y3,z3,v3,p(1)) 
set(p,'FaceColor','yellow')
set(p,'EdgeColor','none')
set(p,'FaceLighting','gouraud')
view(3)
camlight right

axis([-inf inf -inf inf -inf 25]);
