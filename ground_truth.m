clear all;
clc;
close all;

load('OM_dataset.mat');
Xq = flipud(Xq);
Yq = flipud(Yq);
scale_factor = 10;
Zq = scale_factor*flipud(Zq);


meanfunc = [];            % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood

hyp = struct('mean', [], 'cov', [-1.1341 1.3895], 'lik', -5.0313);

% define the vertices of the farm
environment = [135, 230, 230, 190, 190, 140, 80, 150; 20, 20, 60, 70, 115, 115, 50, 50];

% figure();
% patch(environment(1, :), environment(2, :), 'red');
% hold on;
% axis equal;

%% define the farm boundary
ex_polygon = double(inpolygon(Xq, Yq, environment(1, :), environment(2, :))) == 0;
Xq(ex_polygon) = nan; Yq(ex_polygon) = nan; Zq(ex_polygon) = nan;

inputDesign = [Xq(:), Yq(:), Zq(:)];

inputDesign(any(isnan(inputDesign), 2), :) = [];
% Xq = Xq(min(environment(1, :)):max(environment(1, :)), min(environment(2, :)):max(environment(2, :)));
% Yq = Yq(min(environment(1, :)):max(environment(1, :)), min(environment(2, :)):max(environment(2, :)));
% Zq = Zq(min(environment(1, :)):max(environment(1, :)), min(environment(2, :)):max(environment(2, :)));

% hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, inputDesign(1:50:end, 1:2), inputDesign(1:50:end, end))
% pause();

% define lipschitz constant (ppm/meter)
lipschitz = 30;

% kernel hyperparameters are obtained by minimizing the negative marginal log likelihood of OM dataset
length_scale = exp(-.1341);
signal_std = exp(1.3895);
noise_std = exp(-5.0313);
N = 10000; epsilon = 5; delta = 0.8;

% r_max is obtained from lemma 1  
r_max = length_scale*sqrt(-log((signal_std^2+noise_std^2)/(N*signal_std^2)*(1-epsilon^2/(2*signal_std^2*erfinv(delta)^2))));


% these values are chosen by observing the sampled functions for given kernel hyperparameters
a = 0.1; b = 0.1;
lipschitz_1 = 1;


% Covering disks
% [diskX, diskY] = inputDesign(1:2, :)
% meshgrid(min(environment(1, :)):r_max:max(environment(1, :)), min(environment(2, :)):r_max:max(environment(2, :)));

points = inputDesign(:, 1:2);
new = size(points, 1);
i = 1;
% pause();
% Calculate MIS and denote centers of MIS disks by 'points'
while i < new
	index_c = [];
	for j = i + 1 : size(points, 1)
		if (points(i, 1) - points(j, 1))^2 + (points(i, 2) - points(j, 2))^2 <= 4*r_max^2
			index_c = [index_c; j];
		end
	end
	points(index_c, :) = [];
	new = size(points, 1);
	i = i + 1;
end

% sufficiency condition implemented here and alpha is calculated
min_alph = floor((lipschitz + sqrt(2)*lipschitz_1)/epsilon*r_max);
alph = min_alph:5:2*min_alph;
% denominatro in the expression for n_alpha
deno = epsilon - (lipschitz+sqrt(2)*lipschitz_1)*r_max./alph;
% final expression for n_alphaN
n_alph = (sqrt(2)*noise_std*erfinv(delta/(1-a*exp(-lipschitz_1^2/b^2)))./deno).^2-(noise_std/signal_std)^2;
first_occ_tmp = find(n_alph <= 1);
alph = min_alph + 5*first_occ_tmp(1);

figure();
h = surf(Xq, Yq, Zq);
set(h,'LineStyle','none');
% hold on;
axis equal; 
grid off;
% title('Covering the farm with 3r_{max} disks')

% do the preprocessing
points = preprocessing(points, 3*r_max, environment);

viscircles([points(:, 1), points(:, 2)], 3*r_max*ones(size(points, 1), 1), 'LineWidth', 1);
view(2);


% claculat measurement locations by covering 3r_max disk with r_max/alpha disks 
measurement_locations = []
x_test = 80 + 150*rand(5000, 1);
y_test = 20 + 95*rand(5000, 1);
index = inpolygon(x_test, y_test, [135, 230, 230, 190, 190, 140, 80, 150], ...
	 [20, 20, 60, 70, 115, 115, 50, 50]);
test_points = [x_test(index), y_test(index)];
real_test_values = griddata(inputDesign(:, 1), ...
 		inputDesign(:, 2), inputDesign(:, 3), test_points(:, 1), test_points(:, 2), ...
 		'cubic');
fileID = fopen('time_total.txt', 'w');
fileID1 = fopen('measurement_locations.txt', 'w');
% Cover with r_max/alpha radii disks
freq = 50;
for i = 1:size(points, 1)
	i
	[tmp_measurement_locationsX, tmp_measurement_locationsY] = meshgrid(points(i, 1)-3*r_max:r_max*sqrt(2)/alph:points(i, 1)+3*r_max,...
	 points(i, 2)-3*r_max:r_max*sqrt(2)/alph:points(i, 2)+3*r_max);
	lie_inside = inpolygon(tmp_measurement_locationsX, tmp_measurement_locationsY, environment(1, :), environment(2, :));
	% inpolygon(tmp_measurement_locationsX, tmp_measurement_locationsY, [points(j, 1) + 3/sqrt(2)*r_max*cos(pi/4*(1:2:7))],...
	%  [points(j, 2) + 3/sqrt(2)*r_max*sin(pi/4*(1:2:7))]); 
	already = zeros(size(tmp_measurement_locationsX), 'logical');
	for j = 1:i-1
		% already = already|(tmp_measurement_locationsX - points(j, 1)).^2 + (tmp_measurement_locationsY - points(j, 2)).^2 <= 9*r_max^2;
		already = already|inpolygon(tmp_measurement_locationsX, tmp_measurement_locationsY, [points(j, 1) + 3*sqrt(2)*r_max*cos(pi/4*(1:2:7))],...
		 [points(j, 2) + 3*sqrt(2)*r_max*sin(pi/4*(1:2:7))]);
	end
	measurement_locations = [measurement_locations; [tmp_measurement_locationsX(lie_inside&~already), tmp_measurement_locationsY(lie_inside&~already)]];
% pause();
	real_train_values = griddata(inputDesign(:, 1), ...
	 		inputDesign(:, 2), inputDesign(:, 3), measurement_locations(1:freq:end, 1), measurement_locations(1:freq:end, 2), ...
	 		'cubic');

	[ypred, ysd] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, ...
	 		measurement_locations(1:freq:end, :), real_train_values, ...
	 		 test_points);	
	
	fprintf(fileID1,'%d\n', [numel(measurement_locations)/2]);
	if i == 1
		fprintf(fileID,'%d \t %d\n', [i*r_max*82+...
 			numel(real_train_values)/100 numel(find(abs(ypred - real_test_values) > epsilon))/size(test_points, 1)]);
	end

	if i == 2
		fprintf(fileID,'%d \t %d\n', [sum(sum(dist(points(1:i, :))))/2 + i*r_max*82+...
 			numel(real_train_values)/100 numel(find(abs(ypred - real_test_values) > epsilon))/size(test_points, 1)]);
	end


	if i > 2
		fprintf(fileID,'%d \t %d\n', [tsp_solver(points(1:i, 1), points(1:i, 2))+i*r_max*82+...
 			numel(real_train_values)/100 numel(find(abs(ypred - real_test_values) > epsilon))/size(test_points, 1)]);
	end
end


% figure();
% h = surf(Xq, Yq, Zq);
% hold on;
% % scatter(diskX(:), diskY(:));
% set(h,'LineStyle','none')
% axis equal; grid off;
% % viscircles([points(:, 1), points(:, 2)], r_max*ones(size(points, 1), 1));
% viscircles(measurement_locations, r_max/alph*ones(size(measurement_locations, 1), 1));
% scatter(measurement_locations());
% view(2);
