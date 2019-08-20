clear all;
clc;
close all;

load('OM_dataset.mat');
Xq = flipud(Xq);
Yq = flipud(Yq);
scale_factor = 10;
Zq = scale_factor*flipud(Zq);

% [Xq, Yq] = meshgrid(70:240, 10:120);
% Zq = exp(-((Xq-155).^2+(Yq-65).^2)/10^3);

meanfunc = @meanConst;            % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood


% define the vertices of the farm
environment = [135, 230, 230, 190, 190, 140, 80, 150; 20, 20, 60, 70, 115, 115, 50, 50];

% figure();
% patch(environment(1, :), environment(2, :), 'red');
% hold on;
% axis equal;

% kernel hyperparameters are obtained by minimizing the negative marginal log likelihood of OM dataset
length_scale = exp(2.1199);
signal_std = exp(2.9379);
noise_std = exp(-1.6220);
MSE = 0.2*signal_std^2;


hyp = struct('mean', [0], 'cov', [log(length_scale) log(signal_std)], 'lik', log(noise_std));

%% define the farm boundary
ex_polygon = double(inpolygon(Xq, Yq, environment(1, :), environment(2, :))) == 0;
Xq(ex_polygon) = nan; Yq(ex_polygon) = nan; Zq(ex_polygon) = nan;

inputDesign = [Xq(:), Yq(:), Zq(:)];

array_of_nans = any(isnan(inputDesign), 2);

inputDesign(array_of_nans, :) = [];
% Xq = Xq(min(environment(1, :)):max(environment(1, :)), min(environment(2, :)):max(environment(2, :)));
% Yq = Yq(min(environment(1, :)):max(environment(1, :)), min(environment(2, :)):max(environment(2, :)));
% Zq = Zq(min(environment(1, :)):max(environment(1, :)), min(environment(2, :)):max(environment(2, :)));

% hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, inputDesign(1:50:end, 1:2), inputDesign(1:50:end, end))
% pause();

% define lipschitz constant (ppm/meter)
% lipschitz = 30;



% r_max is obtained from lemma 1  
r_max = length_scale*sqrt(-log(1-MSE/signal_std^2));


% % these values are chosen by observing the sampled functions for given kernel hyperparameters
% a = 0.1; b = 0.1;
% lipschitz_1 = 1;


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
alph = 2;

% denominatro in the expression for n_alpha
deno = (1 - MSE/signal_std^2).^(1./alph.^2-1)-1;

% final expression for n_alpha
n_alph = ceil((noise_std/signal_std)^2/deno);

figure();
h = surf(Xq, Yq, Zq);
set(h,'LineStyle','none');
colormap('jet');
axis equal; 
grid off;
view(2)
% title('Covering the farm with 3r_{max} disks')

% do the preprocessing
points = preprocessing(points, 3*r_max, environment);

% viscircles([points(:, 1), points(:, 2)], 3*r_max*ones(size(points, 1), 1), 'LineWidth', 1);

% set of test points
% fileID = fopen('test_points.txt', 'w');

% calculate measurement locations by covering 3r_max disk with r_max/alpha disks 
measurement_locations = [];
% x_test = 80 + 150*rand(1000, 1);
% y_test = 20 + 95*rand(1000, 1);
% index = inpolygon(x_test, y_test, [135, 230, 230, 190, 190, 140, 80, 150], ...
% 	 [20, 20, 60, 70, 115, 115, 50, 50]);
% test_points = [x_test(index), y_test(index)];
% fprintf(fileID,'%d %d \n', test_points');

measurement_locations = load('measurement_locations.txt');
test_points = load('test_points.txt');
real_test_values = griddata(inputDesign(:, 1),inputDesign(:, 2), inputDesign(:, 3), test_points(:, 1), test_points(:, 2));

% test_points(isnan(real_test_values), :) = [];
% real_test_values(isnan(real_test_values)) = [];

% real_test_values = exp(-((test_points(:, 1)-155).^2+(test_points(:, 2)-65).^2)/10^3);
freq = 1;
% fileID = fopen('time_total5.txt', 'w');
% fileID1 = fopen('measurement_locations.txt', 'w');
% Cover with r_max/alpha radii disks
% store = [sum((real_test_values - 0).^2)/numel(real_test_values)];
% store_error =[];
% store_ysd = [];
% points = points(randperm(size(points, 1)), :);
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
	% cum_measurement_locations = measurement_locations(1:i, :);
	real_train_values = griddata(inputDesign(:, 1), ...
	 		inputDesign(:, 2), inputDesign(:, 3), measurement_locations(1:freq:end, 1), measurement_locations(1:freq:end, 2));
	% real_train_values = exp(-((measurement_locations(:, 1)-155).^2+(measurement_locations(:, 2)-65).^2)/10^3);
	
	[ypred, ysd] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, ...
	 		measurement_locations(1:freq:end, :), real_train_values, ...
	 		 test_points);
	% store_error = [store_error, mean((real_test_values - ypred).^2)];
	% store_ysd = [store_ysd, mean(ysd)];
% emp_error = ((real_test_values - ypred).^2 > ysd);
	% scatter(measurement_locations(:, 1), measurement_locations(:, 2));
	% pause();
	
	% fprintf(fileID1,'%d\n', [numel(measurement_locations)]);
	
	% if i == 1
	% 	fprintf(fileID,'%d \t %d \t %d \n', [i*r_max*82+numel(real_train_values)/100 mean(ysd) mean((real_test_values - ypred).^2)]);
	% end

	% if i == 2
	% 	fprintf(fileID,'%d \t %d \t %d \n', [sum(sum(dist(points(1:i, :))))/2 + i*r_max*82+numel(real_train_values)/100 mean(ysd) mean((real_test_values - ypred).^2)]);
	% end

	if i > 2
		tsp_solver(points(1:i, 1), points(1:i, 2))
		% fprintf(fileID,'%d \t %d\n', [tsp_solver(points(1:i, 1), points(1:i, 2)) + i*r_max*82+numel(real_train_values)/100 mean(ysd)]);
		% fprintf(fileID,'%d \t %d \t %d\n', [tsp_solver(points(1:i, 1), points(1:i, 2)) + i*r_max*82+numel(real_train_values)/100 mean(ysd) mean((real_test_values - ypred).^2)]);
	end
	% numel(find(abs(ypred - real_test_values) > epsilon))/size(test_points, 1);
end

% pause();

% fprintf(fileID1, '%d\t%d\n', measurement_locations');

% for seed = 1:1000
% seed
% K = feval(covfunc, hyp.cov, [measurement_locations; test_points]);
% K = K + noise_std^2*eye(size(K));
% mu = feval(meanfunc, hyp.mean, [measurement_locations; test_points]);
% num_measure_loc = size(measurement_locations, 1);



% % real_train_values = griddata(inputDesign(:, 1), ...
% %   	inputDesign(:, 2), inputDesign(:, 3), measurement_locations(1:freq:end, 1), measurement_locations(1:freq:end, 2));


% % % scatter3(measurement_locations(1:freq:end, 1), measurement_locations(1:freq:end, 2), real_train_values);
% % % pause();
% real_values = chol(K)'*gpml_randn(seed, size([measurement_locations; test_points], 1), 1) + mu;
% % real_test_values = chol(K)'*gpml_randn(seed, size(test_points, 1), 1) + mu + noise_std*gpml_randn(seed, size(test_points, 1), 1);

% % [ypred, ysd] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, ...
% % 	 		measurement_locations(1:freq:end, :), real_train_values(1:num_measure_loc, :), ...
% % 	 		 [inputDesign(:, 1), inputDesign(:, 2)]);


% [ypred, ysd] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, ...
% 	 		measurement_locations(1:freq:end, :), real_values(1:num_measure_loc), ...
% 	 		 test_points);

% % pilot = [Zq(:)];
% % pilot(array_of_nans) = nan;
% % pilot(~array_of_nans) = ypred;
% % % scatter3(inputDesign(1:freq:end, 1), inputDesign(1:freq:end, 2), ypred);
% % % pause();
% % emp_error = ((real_values(num_measure_loc:end, num_measure_loc+1:end) - ypred).^2 > ysd);

% fileID1 = fopen(['emp_error_' num2str(seed) '.txt'], 'w');
% fileID2 = fopen(['ysd_' num2str(seed) '.txt'], 'w');

% fprintf(fileID1,'%d\n', (real_values(num_measure_loc+1:end, :) - ypred).^2);
% fprintf(fileID2,'%d\n', ysd);
% end
% figure();
% h = surf(Xq, Yq, reshape(pilot, size(Xq)));
% set(h,'LineStyle','none');
% colormap('jet');
% axis equal; 
% grid off;
% view(2);
% figure();
% plot(store);
% hold on;
% plot([1, 5], [MSE, MSE],'r');

% figure();
% h = surf(Xq, Yq, abs(Zq - reshape(pilot, size(Xq))));
% set(h,'LineStyle','none');
% colormap('jet');
% axis equal; 
% grid off;
% view(2);


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
