clear all;
clc;
initial_position = [0, 0];

window_sizes = [4.0 2.0 1.0 0.1];
robot_speeds = [0.1 1 10];


for index_window = 1 : numel(window_sizes)
	window_size = window_sizes(index_window);
	for index_speed = 1 : numel(robot_speeds)
		robot_speed = robot_speeds(index_speed);   

% Extract the data from MI
path_to_MI = ['/home/varun/codes_for_sensor/MI_speed_' num2str(robot_speed) '/'];
data_MI = load([path_to_MI 'plot_MI' '_' num2str(initial_position(1)) '_' num2str(initial_position(2)) '_'  'w' num2str(window_size)  '_r' num2str(robot_speed) '.txt']);

% Extract the data from Entropy 
path_to_entropy = ['/home/varun/codes_for_sensor/Entropy_speed_' num2str(robot_speed) '/'];
data_Entropy = load([path_to_entropy 'plot_entropy' '_' num2str(initial_position(1)) '_' num2str(initial_position(2)) '_'  'w' num2str(window_size)  '_r' num2str(robot_speed) '.txt']);

% Extract the data from Algorithm 
path_to_alg = ['/home/varun/codes_for_sensor/non_adaptive_' num2str(robot_speed) '/'];
data_Alg = load([path_to_alg 'plot_non_adaptive' '_' num2str(initial_position(1)) '_' num2str(initial_position(2))  '_r' num2str(robot_speed) '.txt']);



cut_off = 50;
% load('/home/varun/codes_for_sensor/Entropy_speed_0.1/')
plot(data_Entropy(1: end - cut_off, 1), data_Entropy(1: end - cut_off, 2), ':', 'DisplayName','Entropy based Planning', 'LineWidth',2);
hold on;
plot(data_MI(1: end - cut_off, 1), data_MI(1: end - cut_off, 2), '--', 'DisplayName','MI based Planning', 'LineWidth',2);
hold on;
figure1 = plot(data_Alg(:, 1), data_Alg(:, 2),'DisplayName','Our Algorithm', 'LineWidth',2);
hold on;
% xlabel({'Time taken by the robot with'; ['robot speed ='  num2str(robot_speed) ' units']}, 'FontSize',12);
xlabel('Time taken by the robot', 'FontSize', 12)
ylabel({'Percentage of points having prediction' ; ' error more than \epsilon %'},'FontSize',12);
%axis([0 1500 0 100]);


lgd = legend('show');
lgd.FontSize = 12;
lgd.TextColor = 'black';

file_name_for_figure = ['r' num2str(robot_speed) '_' 'w' num2str(window_size)];
% print -depsc ['r' num2str(robot_speed '_' 'w' num2str(window_size) '.eps'];
saveas(figure1, file_name_for_figure, 'epsc');
close all;
end
end

% import_entropy_0_0_w4_r_10 = load('plot_entropy_0_0_w4_r_10.txt');
% import_entropy_0_0_w2_r_10 = load('plot_entropy_0_0_w2_r_10.txt');
% import_entropy_0_0_w1_r_10 = load('plot_entropy_0_0_w1_r_10.txt');
% import_entropy_0_0_w_1_r_10 = load('plot_entropy_0_0_w_1_r_10.txt');

% plot(import_entropy_0_0_w4_r_10(1 : length(import_entropy_0_0_w4_r_10)/2),import_entropy_0_0_w4_r_10(length(import_entropy_0_0_w4_r_10)/2 + 1 : end), 'r');
% hold on;

% plot(import_entropy_0_0_w2_r_10(1 : length(import_entropy_0_0_w2_r_10)/2),import_entropy_0_0_w2_r_10(length(import_entropy_0_0_w2_r_10)/2 + 1 : end), 'b');
% hold on;

% plot(import_entropy_0_0_w1_r_10(1 : length(import_entropy_0_0_w1_r_10)/2),import_entropy_0_0_w1_r_10(length(import_entropy_0_0_w1_r_10)/2 + 1 : end), 'g');
% hold on;

% plot(import_entropy_0_0_w_1_r_10(1 : length(import_entropy_0_0_w_1_r_10)/2),import_entropy_0_0_w_1_r_10(length(import_entropy_0_0_w_1_r_10)/2 + 1 : end),'y');
