function [points_new] =  preprocessing(points, radii, polygo)
% diameter, center, and image size.
% First create the image.
load('OM_dataset.mat');
Xq = flipud(Xq);
Yq = flipud(Yq);
Zq = flipud(Zq);

imageSizeX = 250;
imageSizeY = 150;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.


poly_c = inpolygon(columnsInImage, rowsInImage, polygo(1, :), polygo(2, :));
max_inter = 0;
points_new = [];

% close the writer object
% apply greedy algorithm
while sum(sum(poly_c)) > 0
	relevantPixels = zeros(size(columnsInImage), 'logical');
	for j = randperm(size(points, 1))
		relevantPixels_tmp = poly_c&(rowsInImage - points(j, 2)).^2+ (columnsInImage - points(j, 1)).^2 <= radii.^2;
		if sum(sum(relevantPixels_tmp)) > sum(sum(relevantPixels))
			relevantPixels = relevantPixels_tmp;
			var_tmp = j;
		end
	end
	points_new = [points_new; points(var_tmp, :)];
	points(var_tmp, :) = [];
	% imshow(double(poly_c));
	poly_c = poly_c & ~relevantPixels;
end
% figure();
% image(relevantPixels);
% colormap([0 0 0; 1 1 1]);
% title('Binary image of a circle');
end
