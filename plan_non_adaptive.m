clc;
clear all;

l = 0.5;
epsilon = 2;
delta = 0.3;
max_diff = 15;
noise = 0.1;
specified_number = 500;

l2 = 50; 
zeta = (2 * l2 * epsilon^2 * (5 * noise)^2) / (max_diff^2 * log(2/delta));

lambda = sqrt(-2 * l^2 * log(1 - zeta));
length_e = 4; width_e = 4;
epsilon_per = 15;
% robot speed in meters/minute
robot_speed = 5;
% measure time in minutes
measure_time = .05;

m_alpha = round( (5 * noise) ^ 2 / ((1 - zeta)^-0.75 - 1));

% subplot(2, 2, 1);
% rectangle('Position',[0 0 length_e width_e]);
% hold on;


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
			grnd_trth = [grnd_trth; all_X(i) all_Y(i) (all_X(i)-2)^2 + (all_Y(i)-2)^2];
			for j = 1 : m_alpha
				collected_sample = normrnd(actual_values(all_X(i), all_Y(i), length_e, width_e) , 0.5);
				%grnd_trth = [grnd_trth; all_X(i) all_Y(i) (all_X(i)-2)^2 + (all_Y(i)-2)^2];
				design_matrix = [design_matrix ; all_X(i) all_Y(i) collected_sample];
			end

		end
end

%Ensure that specifies sensing locations don't go beyond total sensing locations
if specified_number >= size(all_X, 1)
	specified_number =  size(all_X, 1);
end

kparams0 = [1 , 0.5];

xx = 0:0.1:length_e;
yy = 0:0.1:width_e;

[X_pred, Y_pred] = meshgrid(xx, yy);

num_of_mispredict = [];
number_of_sensing_spots = 1;
final_pred = [X_pred(:) Y_pred(:)];
true_value = zeros(size(X_pred,1));

for i = 1 : size(X_pred, 1)
		for j = 1 : size(X_pred, 1)
			true_value(i, j) = actual_values(X_pred(i, j), Y_pred(i, j), 4, 4);  
		end
	end


while number_of_sensing_spots <= specified_number
	
	gprMdl = fitrgp(design_matrix(1:number_of_sensing_spots, 1:2), design_matrix(1:number_of_sensing_spots, 3), ...
		'KernelFunction','squaredexponential','KernelParameters', kparams0);
	
	[ypred, ysd, yint] = predict(gprMdl, final_pred);
	ypred = reshape(ypred, size(X_pred));
	error_variable =  abs( 100 * (true_value - ypred)./ true_value);
	num_of_mispredict = [num_of_mispredict; size(find(error_variable > epsilon_per), 1)];
	number_of_sensing_spots = number_of_sensing_spots + 1;
end


total_measure_time = [1 : specified_number ]' * measure_time;

% Total time to visit the sensing locations
total_travel_time = cumsum( [0; sqrt( sum (diff ([design_matrix(1 : specified_number, 1) design_matrix(1:specified_number,2)]).^2, ...
	2))])/ robot_speed;

plot(total_travel_time + total_measure_time , 100 * num_of_mispredict / 1681);
xlabel('Time spent by robot in Minutes');
ylabel('Percentage of points having error more than epsilon');