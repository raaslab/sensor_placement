clc;
clear all;

l = 0.8;
epsilon = 8.0;
delta = 0.3;
max_diff = 15;
sensor_noise_std = 0.5;
% specified_number = 1000;
resolution = 0.1;
zeta = (2 *  epsilon^2 * sensor_noise_std^2) / (max_diff^2 * log(2/delta));

lambda =  sqrt(-2 * l^2 * log(1 - zeta))
length_e = 4; width_e = 4;
epsilon_per = 15;
% robot speed in meters/minute
% robot_speed = 1;
% measure time in minutes
measure_time = 10^-2;
specified_budget = 2000;


m_alpha = round( sensor_noise_std ^ 2 / ((1 - zeta) ^ -0.75 - 1));

% subplot(2, 2, 1);
% rectangle('Position',[0 0 length_e width_e]);
% hold on;

meanfunc = [];                    % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood
hyp = struct('mean', [], 'cov', [log(l) log(1)], 'lik', log(sensor_noise_std));

spaceX_store = [];
spaceY_store = [];
t = linspace(0, 2 * pi);

for spaceX = sqrt(2) * lambda : 2 * lambda : length_e 
	for spaceY = sqrt(2) * lambda : 2 * lambda : width_e
		spaceX_store = [spaceX_store, spaceX];
		spaceY_store = [spaceY_store, spaceY];
		%plot(spaceX + 2 * lambda * cos(t), spaceY + 2 * lambda * sin(t));
		%hold on;
	end
end
% axis equal;
% scatter(spaceX_store, spaceY_store, 'b');

points = [spaceX_store; spaceY_store];
new = 9999;
i = 1;

% Calculate MIS and denote centre of MIS disks by 'points'
while i < new
	index_c = [];
	for j = i + 1 : size(points, 2)
		if (points(1, i) - points(1, j))^2 + (points(2, i) - points(2, j))^2 <= 16 * lambda^2
			index_c = [index_c; j];
		end
	end
	for len = size(index_c, 1) : -1 : 1
		points(: , index_c(len, 1)) = [];
	end
	new = size(points, 2);
	i = i + 1;
end

% subplot(2, 2, 2);
% for i  = 1 : size(points, 2)
% 	plot(points(1, i) + 2 * lambda * cos(t), points(2, i) + 2 * lambda * sin(t));
% 	%plot(points(1, i) + 6 * lambda * cos(t), points(2, i) + 6 * lambda * sin(t));
% 	%rectangle('Position',[points(1, i)-6*lambda  points(2, i)-6*lambda 12*lambda 12*lambda]);
% 	%[XX, YY] = meshgrid(points(1, i) - 5.5*lambda : lambda/sqrt(2) : points(1, i) + 5.5*lambda, points(2, i) - 5.5*lambda : lambda/sqrt(2) : points(2, i) + 5.5*lambda);
% 	%all_X = [all_X ; XX(:)]; all_Y = [all_Y ; YY(:)];
% 	hold on;
% end



% subplot(2, 2, 3);
% rectangle('Position',[0 0 length_e width_e]);
% hold on;
all_X = [] ; all_Y = [];
for i  = 1 : size(points, 2)
%	plot(points(1, i) + 2 * lambda * cos(t), points(2, i) + 2 * lambda * sin(t));
	%plot(points(1, i) + 6 * lambda * cos(t), points(2, i) + 6 * lambda * sin(t));
	%rectangle('Position',[points(1, i)-6*lambda  points(2, i)-6*lambda 12*lambda 12*lambda]);
	[XX, YY] = meshgrid(points(1, i) - 5.5 * lambda : lambda/sqrt(2) : points(1, i) + 5.5 * lambda, points(2, i) - 5.5*lambda : lambda/sqrt(2) : points(2, i) + 5.5*lambda);
	all_X = [all_X ; XX(:)]; all_Y = [all_Y ; YY(:)];
	%hold on;
end

design_matrix = [];
grnd_trth = [];


for i = 1 : length(all_X)
		if 0 < all_X(i) && all_X(i) < length_e && 0 < all_Y(i) && all_Y(i) < width_e
			for j = 1 : m_alpha
				collected_sample = normrnd(actual_values([all_X(i) all_Y(i)], length_e, width_e) , sensor_noise_std);
				%grnd_trth = [grnd_trth; all_X(i) all_Y(i) (all_X(i)-2)^2 + (all_Y(i)-2)^2];
				design_matrix = [design_matrix ; all_X(i) all_Y(i) collected_sample];
			end

		end
end

%Ensure that specifies sensing locations don't go beyond total sensing locations
% if specified_number >= size(design_matrix, 1)
% 	specified_number =  size(design_matrix, 1);
% end

xx = 0:resolution:length_e;
yy = 0:resolution:width_e;

[X_pred, Y_pred] = meshgrid(xx, yy);


final_pred = [X_pred(:) Y_pred(:)];
true_value = zeros(size(X_pred,1));

for i = 1 : size(X_pred, 1)
	for j = 1 : size(X_pred, 1)
		true_value(i, j) = actual_values([X_pred(i, j) Y_pred(i, j)], length_e, width_e);  
	end
end

surf(xx, yy, true_value);
pause();
robot_speeds = [1.0];
initial_positions = round( size(design_matrix, 1) * [0.2 : 0.2 : 0.2]);
for index_position = 1 : numel(initial_positions)
	initial_position = initial_positions(1, index_position);
	design_matrix(initial_position, 1:2);
	for index_speeds = 1 : numel(robot_speeds)
		robot_speed = robot_speeds(1, index_speeds);

specified_budget = 2000;
design_matrix = [design_matrix(initial_position + 1 : end, :); design_matrix(1 : initial_position, :)];  

maximum_budget = [1 : size(design_matrix, 1)]' * measure_time + cumsum( [0; sqrt( sum (diff ([design_matrix(:, 1) design_matrix(:,2)]).^2, 2))])/ robot_speed;

if specified_budget >= maximum_budget(end, end)
	specified_budget = maximum_budget(end, end);
end

num_of_mispredict = [];
entropy_post = [];
number_of_sensing_spots = 1;
budget = measure_time;
frequency = 20;
while budget <= specified_budget
	budget
	 % scatter(design_matrix(number_of_sensing_spots,1),design_matrix(number_of_sensing_spots, 2));
	 % hold on;
	 % pause(0.01);
	 %   gprMdl = fitrgp(design_matrix(1 : number_of_sensing_spots, 1:2), design_matrix(1 : number_of_sensing_spots, 3), ...
		% 'KernelFunction','squaredexponential','KernelParameters', kparams0);
	if rem (number_of_sensing_spots, frequency) == 0
		[ypred, ysd] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, ...
	 		design_matrix(1 : number_of_sensing_spots, 1 : 2), design_matrix(1 : number_of_sensing_spots, 3), final_pred);
	
		ypred = reshape(ypred, size(X_pred));

		error_variable =  abs( 100 * (true_value - ypred)./ true_value);
		num_of_mispredict = [num_of_mispredict; size(find(error_variable > epsilon_per), 1)];
		
		% Calculate Entropy Posterior
		entropy_post = [entropy_post; sum(sum(0.5 * log(2 * pi * exp(1) * ysd)))];
	end

	% Calculate the total time spent till now	
	total_measure_time = [1 : number_of_sensing_spots ]' * measure_time;
	total_travel_time = cumsum( [0 ; sqrt( sum (diff ([design_matrix(1 : number_of_sensing_spots, 1) design_matrix(1:number_of_sensing_spots ,2)]).^2, 2))])/ robot_speed;
 	budget = total_travel_time(end, end) + total_measure_time(end, end);
 	number_of_sensing_spots = number_of_sensing_spots + 1;
 	if number_of_sensing_spots > size(design_matrix, 1)
 		break;
 	end
end


% total_measure_time = [1 : number_of_sensing_spots - 1]' * measure_time;

% Total time to visit the sensing locations
% total_travel_time = cumsum( [0; sqrt( sum (diff ([design_matrix(1 : number_of_sensing_spots - 1, 1) design_matrix(1:number_of_sensing_spots - 1,2)]).^2, ...
% 	2))])/ robot_speed;

% Plot Entropy
figure;
plot(total_travel_time(frequency: frequency: end) + total_measure_time(frequency: frequency: end) , entropy_post, 'r');
xlabel('Time spent');
ylabel('Entropy of posterior distribution');

figure;
plot(total_travel_time(frequency: frequency: end) + total_measure_time(frequency: frequency: end) , 100 * num_of_mispredict / numel(X_pred), 'b');
xlabel('Time spent');
ylabel('% of points having error more than \epsilon');

% pause();
% xlabel('Time spent by robot in Minutes');
% ylabel('Percentage of points having error more than epsilon');
% title('Non - Adaptive Path Planning')
filename = ['plot_non_adaptive' '_' num2str(initial_position) '_' '_r' num2str(robot_speed) '.txt'];
fileID = fopen(filename, 'w');
% fileID = fopen('plot_non_adaptive.txt','w');
fprintf(fileID,'%d \t %d\n', [total_travel_time(frequency : frequency : end) + total_measure_time(frequency : frequency : end)  100 * num_of_mispredict/ numel(X_pred)]' );

end
end