clear all;
clc;
l = 0.8;
length_e = 4; width_e = 4;
epsilon_per = 15;
resolution = 0.1;
xx = 0:resolution:length_e;
yy = 0:resolution:width_e;
sensor_noise_std = 0.5;
length_e = 4; width_e = 4;
%window_size = 4.0;
specified_budget = 100;

% robot speed in meters/minute
robot_speed = 1;

meanfunc = [];                    % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood

hyp = struct('mean', [], 'cov', [log(l) log(1)], 'lik', log(sensor_noise_std));
%hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1:2) , design_matrix(:,3))

% Measure time in minutes
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

initial_positions = [0 0];
window_sizes = [4.0]';

for index_position = 1 : size(initial_positions, 1)
	initial_position = initial_positions(index_position, :)
	for index_window = 1 : size(window_sizes, 1)
		window_size = window_sizes(index_window)

% initial_position = [3 2];

design_matrix = [initial_position(1,1) initial_position(1,2) normrnd(actual_values([initial_position(1,1) initial_position(1,1)], length_e, width_e) , 0.1)];

[mu_total, s2_total] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), final_pred);
mu_total = reshape(mu_total, size(X_pred));
entropy_post = [sum(sum(0.5 * log(2 * pi * exp(1) * s2_total)))];

% Calculate the error at each grid location
error_variable = abs(100 * (true_value - mu_total)./true_value);

num_of_mispredict = [size(find(error_variable > epsilon_per), 1)];

budget = measure_time;

total_travel_time_arr = [0];
total_measure_time_arr = [measure_time];

% Calculate data values at complement locations
design_matrix_bar = [final_pred actual_values(final_pred, length_e, width_e)];

while budget <= specified_budget

	returned_window = return_window(design_matrix(end,:), window_size);
	[mu s2] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), returned_window);

	design_matrix_bar = removerows(design_matrix_bar, 'ind', find(ismember (design_matrix_bar, design_matrix(end , 1:3), 'rows')));

	% Calculate Denomenator of the Expression for Mutual Information
	[mu_bar s2_bar] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix_bar(:, 1 : 2), design_matrix_bar(:, 3), returned_window);

	new_x = returned_window(find((s2 ./ s2_bar) == max(s2./s2_bar)), 1);
	new_y = returned_window(find((s2 ./ s2_bar) == max(s2./s2_bar)), 2);

	design_matrix = [design_matrix; new_x(1,1) new_y(1,1) normrnd(actual_values([new_x(1,1)  new_y(1,1)], length_e, width_e) , sensor_noise_std)];

	[mu_total, s2_total] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), final_pred);
	mu_total = reshape(mu_total, size(X_pred));
	
	% Calculate the posterior entropy
	entropy_post = [entropy_post; sum(sum(0.5 * log(2 * pi * exp(1) * s2_total)))];

	% Calculate the error at each grid location
	error_variable = abs(100 * (true_value - mu_total)./true_value);
	num_of_mispredict = [num_of_mispredict; size(find(error_variable > epsilon_per), 1)];

	total_measure_time = size(design_matrix, 1) * measure_time;
	
	% total_travel_time = cumsum( [0 ; sqrt( sum (diff ([design_matrix(:,1) design_matrix(:,2)]).^2, 2))])/ robot_speed;
	if size(design_matrix, 1) <=2
		total_travel_time = pdist(design_matrix(:, 1:2));
	else
		total_travel_time = tsp_solver(design_matrix(:, 1), design_matrix(:, 2))/robot_speed;
	end 	
 	budget = total_travel_time + total_measure_time;
 	
 	total_measure_time_arr = [total_measure_time_arr; total_measure_time]; 
 	total_travel_time_arr = [total_travel_time_arr; total_travel_time];
 	pause(0.001);

end


figure;
plot(total_travel_time_arr + total_measure_time_arr , entropy_post, 'r');
xlabel('Time spent');
ylabel('Entropy of posterior distribution');


figure;
plot(total_travel_time_arr + total_measure_time_arr , 100 * num_of_mispredict/numel(X_pred), 'b' );
xlabel('Time spent');
ylabel('% of points having error more than \epsilon');


%plot(total_travel_time + total_measure_time , 100 * num_of_mispredict/ numel(X_pred));
filename = ['plot_MI' '_' num2str(initial_position(1)) '_' num2str(initial_position(2)) '_'  'w' num2str(window_size)  '_r' num2str(robot_speed) '.txt'];
fileID = fopen(filename, 'w');

% fprintf(fileID,'Window SIZE %d Initial %d %d \n', window_size, initial_position);
fprintf(fileID,'%d \t %d\n', [total_travel_time_arr + total_measure_time_arr  100 * num_of_mispredict/ numel(X_pred)]' );
end 
end
