clear all;
clc;
length_e = 4; width_e = 4;
epsilon_per = 15;
resolution = 0.1;
xx = 0:resolution:length_e;
yy = 0:resolution:width_e;
sensor_noise_std = 0.1;
length_e = 4; width_e = 4;
window_size = 2.0;
num_of_sensing_locations = 100;

% robot speed in meters/minute
robot_speed = 10^8;

meanfunc = [];                    % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood

hyp = struct('mean', [], 'cov', [1 0.5], 'lik', log(sensor_noise_std));
%hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1:2) , design_matrix(:,3))
% measure time in minutes
measure_time = 1;

[X_pred, Y_pred] = meshgrid(xx, yy);
final_pred = [X_pred(:) Y_pred(:)];

true_value = zeros(size(X_pred,1));
for i = 1 : size(X_pred, 1)
	for j = 1 : size(X_pred, 1)
		true_value(i, j) = actual_values([X_pred(i, j) Y_pred(i, j)], 4, 4);  
	end
end


final_pred = [X_pred(:) Y_pred(:)];




initial_position = [0 0];

design_matrix = [initial_position(1,1) initial_position(1,2) normrnd(actual_values([initial_position(1,1) initial_position(1,1)], length_e, width_e) , 0.1)];
% 4 0 normrnd(actual_values(4, 0, length_e, width_e) , 0.1);
% 4 4 normrnd(actual_values(4, 4, length_e, width_e) , 0.1);
% 0 4 normrnd(actual_values(0, 4, length_e, width_e) , 0.1)];
% 2 2 normrnd(actual_values(2, 2, length_e, width_e) , 0.1)
% 2 0 normrnd(actual_values(2, 0, length_e, width_e) , 0.1)
% 0 2 normrnd(actual_values(0, 2, length_e, width_e) , 0.1)
% 2 4 normrnd(actual_values(2, 4, length_e, width_e) , 0.1)
% 4 2 normrnd(actual_values(4, 2, length_e, width_e) , 0.1)];




[mu_total s2_total] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), final_pred);
mu_total = reshape(mu_total, size(X_pred));

% Calculate the error at each grid location
error_variable = abs(100 * (true_value - mu_total)./true_value);

num_of_mispredict = [size(find(error_variable > epsilon_per), 1)];

i = 1;

design_matrix_bar = [final_pred actual_values(final_pred, length_e, width_e)];

while i <= num_of_sensing_locations

%y = sin(3*x_hori) + sin(3*x_ver) + 0.1*gpml_randn(0.9, 20, 1);  % 20 noisy training targets
  
%xs = linspace(-3, 3, 41)';                  % 61 test inputs 


returned_window = return_window(design_matrix(end,:), window_size);


[mu s2] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), returned_window);

design_matrix_bar = removerows(design_matrix_bar, 'ind', find(ismember (design_matrix_bar, design_matrix(end , 1:3), 'rows')));


% s2_bar = [];
% for row_index = 1 : size(returned_window, 1)
% 	comp = removerows(design_matrix_bar, 'ind', find(ismember (design_matrix_bar, design_matrix_bar (row_index, :), 'rows')));

% Calculate Denomenator of the Expression for Mutual Information
[mu_bar s2_bar] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix_bar(:, 1 : 2), design_matrix_bar(:, 3), returned_window);

% 	s2_bar = [s2_bar; s2_bar_t];
% end
% window_size = 0.95 * window_size;
%Construct a window to consider variance in nearby regions


new_x = returned_window(find((s2 ./ s2_bar) == max(s2./s2_bar)), 1);
new_y = returned_window(find((s2 ./ s2_bar) == max(s2./s2_bar)), 2);

%s2 = reshape(s2, size(X_pred));

% [column_max , row_max] = quorem(sym(find(s2 == max(max(s2)))), sym(size(X_pred, 1)));

% column_max = double(column_max(1,1)); row_max = double(row_max(1,1)) - 1;

% if row_max == -1
% 	column_max = double(column_max(1,1)); row_max = double(row_max(1,1)) + size(X_pred, 1); 
% end

design_matrix = [design_matrix; new_x(1,1) new_y(1,1) normrnd(actual_values([new_x(1,1)  new_y(1,1)], length_e, width_e) , sensor_noise_std)];

[mu_total s2_total] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), final_pred);
mu_total = reshape(mu_total, size(X_pred));

% Calculate the error at each grid location
error_variable = abs(100 * (true_value - mu_total)./true_value);
num_of_mispredict = [num_of_mispredict; size(find(error_variable > epsilon_per), 1)];

% error12_a = error_variable;
% subplot(2,1,1);
% surf(X_pred, Y_pred, obj);


% subplot(2,1,2);
% surf(X_pred, Y_pred, mu);
% title(sprintf('%d', i));
% pause(0.1);

% surf(X_pred, Y_pred, reshape(s2_total, size(X_pred)));
% pause();
total_travel_time = [ 0 ; cumsum( [sqrt( sum (diff ([design_matrix(:,1) design_matrix(:,2)]).^2, 2))])/ robot_speed];

% if i = 1
% 	total_travel_time = [0];
% end


total_measure_time = [1 : size(design_matrix, 1) ]' * measure_time;


subplot(1,2,1)
scatter(design_matrix(1:end,1),design_matrix(1:end,2))
axis([0 length_e 0 width_e]);

subplot(1,2,2)
plot(total_travel_time + total_measure_time , 100 * num_of_mispredict/ numel(X_pred) );

i = i + 1;
pause();
end

[mu_total s2_total] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, design_matrix(:, 1 : 2), design_matrix(:, 3), final_pred);
mu_total = reshape(mu_total, size(X_pred));
error_variable = abs(100 * (true_value - mu_total) ./ true_value);
num_of_mispredict = [num_of_mispredict; size(find(error_variable > epsilon_per), 1)];

% plot(100 * num_of_mispredict/numel(X_pred));
% xlabel('Number of sensing locations');
% ylabel('Percentage of points having error more than specified value');

% mu = reshape(mu, size(X_pred));
% %f = [mu+2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
% %fill([xs; flipdim(xs,1)], f, [7 7 7]/8)
% %hold on; plot(xs, mu); 
% %surf(x_hori, x_ver, y, '+')
% %s2
% % surf(X_pred, Y_pred, reshape(s2, size(X_pred)));
% %surf(X_pred, Y_pred, reshape(mu, size(X_pred)));

% Total measure time = Number of sampling locations * Measure time
total_measure_time = [1 : size(design_matrix, 1) ]' * measure_time;

% Total time to visit the sensing locations
total_travel_time = cumsum( [0 ; sqrt( sum (diff ([design_matrix(:,1) design_matrix(:,2)]).^2, 2))])/ robot_speed;

% % error_variable = abs(25 * (obj - mu)./obj);
% % save('error12_adaptive.txt', 'error_variable', '-ASCII');
plot(total_travel_time + total_measure_time , 100 * num_of_mispredict/ 1681);
fileID = fopen('plot_adaptive.txt','w');
fprintf(fileID,'%d \n', [total_travel_time + total_measure_time ; 100 * num_of_mispredict/ 1681] );
% % surf(X_pred, Y_pred, error_variable);
xlabel('Time spent by robot in Minutes');
ylabel('Percentage of points having error more than epsilon');
title('Adaptive Path Planning')