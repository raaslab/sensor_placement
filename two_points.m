clear all;
clc;
close all;

signal_std = exp(2.9379);
MSE = 0.2*signal_std^2;

store_norm = [];
store_max = [];
diffi = [];
for j = 1:1000
	diffi = [diffi, load(['emp_error_' num2str(j) '.txt'])];
end
store_mis = [];

for i =1:999
	main = load(['ysd_' num2str(i) '.txt']);
	% main = main;
	temp = mean(diffi(:, 1:i), 2);
	store_norm = [store_norm; max(temp)];
	% store_mis = [store_mis; sum(temp > MSE)*100/numel(temp)];
	% store_max = [store_max; norm(main - temp, Inf)];
	% store_norm = [store_norm; temp];
end

plot([1, 1000], [MSE, MSE],'r');
hold on;
plot(store_norm, 'b');
% hold on;
% plot(store_max, 'b');