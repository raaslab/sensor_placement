clear all;
clc;

resolution = 0.1;
length_e = 4; width_e = 4;
epsilon_per = 15;
xx = 0:resolution:length_e;
yy = 0:resolution:width_e;
sensor_noise_std = 0.1;
length_e = 4; width_e = 4;
% window_size = 0.1;
specified_budget = 2000;

% robot speed in meters/minute
robot_speed = 0.1;

meanfunc = [];                    % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood

hyp = struct('mean', [], 'cov', [0 0], 'lik', log(sensor_noise_std));

%measure time in minutes
measure_time = 1;

[X_pred, Y_pred] = meshgrid(xx, yy);
final_pred = [X_pred(:) Y_pred(:)];

true_value = zeros(size(X_pred,1));
for i = 1 : size(X_pred, 1)
	for j = 1 : size(X_pred, 1)
		true_value(i, j) = actual_values([X_pred(i, j) Y_pred(i, j)], length_e, width_e);  
	end
end


final_pred = [X_pred(:) Y_pred(:)];



% Specify Starting Location for Sampling

% initial_position = [3 3];
initial_positions = [0 0; 1 1; 2 2; 3 2; 3 3];
window_sizes = [4.0 2.0 1.0 0.1]';

for index_position = 1 : size(initial_positions, 1)
	initial_position = initial_positions(index_position, :)
	for index_window = 1 : size(window_sizes, 1)
		window_size = window_sizes(index_window)


design_matrix = [initial_position(1,1) initial_position(1,2) normrnd(actual_values([initial_position(1,1) initial_position(1,1)], length_e, width_e) , 0.1)];
%hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1:2) , design_matrix(:,3));
mu_total = reshape(gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), final_pred), size(X_pred));

% Calculate the error at each grid location
error_variable = abs(100 * (true_value - mu_total)./true_value);

% Calculate Points of high Error
num_of_mispredict = [size(find(error_variable > epsilon_per), 1)];


budget = measure_time;
while budget <= specified_budget

	% Returns Window of specified Size
	returned_window = return_window(design_matrix(end,:), window_size);
	[mu s2] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), returned_window);
	
	% Calculates New Sampling Location Based on highest entropy
	new_x = returned_window(find(s2 == max(s2)), 1);
	new_y = returned_window(find(s2 == max(s2)), 2);
	
	design_matrix = [design_matrix; new_x(1,1) new_y(1,1) normrnd(actual_values([new_x(1,1)  new_y(1,1)], length_e, width_e) , sensor_noise_std)];
	%hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1:2) , design_matrix(:,3));
	% Calculate Posterior Mean and Variance
	mu_total = reshape(gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), final_pred), size(X_pred));

	% Calculate the error at each grid location
	error_variable = abs(100 * (true_value - mu_total)./true_value);
	
	% Calculate percentage of points having high error
	num_of_mispredict = [num_of_mispredict; size(find(error_variable > epsilon_per), 1)];
		
	total_measure_time = [1 : size(design_matrix, 1) ]' * measure_time;
	total_travel_time = cumsum( [0 ; sqrt( sum (diff ([design_matrix(:,1) design_matrix(:,2)]).^2, 2))])/ robot_speed;
 	budget = total_travel_time(end, end) + total_measure_time(end, end);
end


% Total measure time = Number of sampling locations * Measure time
% total_measure_time = [1 : size(design_matrix, 1) ]' * measure_time;

% Total time to visit the sensing locations
% total_travel_time = cumsum( [0 ; sqrt( sum (diff ([design_matrix(:,1) design_matrix(:,2)]).^2, 2))])/ robot_speed;


% plot(total_travel_time + total_measure_time , 100 * num_of_mispredict/numel(X_pred) );
% pause()
filename = ['plot_entropy' '_' num2str(initial_position(1)) '_' num2str(initial_position(2)) '_'  'w' num2str(window_size)  '_r' num2str(robot_speed) '.txt'];
fileID = fopen(filename, 'w');
% fprintf(fileID,'Window SIZE %d Initial %d %d \n', window_size, initial_position);
fprintf(fileID,'%d \t %d\n', [total_travel_time + total_measure_time  100 * num_of_mispredict/ numel(X_pred)]' );
end
end
