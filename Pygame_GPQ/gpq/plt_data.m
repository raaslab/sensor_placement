clear all;
clc;

data = load('reward.txt');
scatter3(data(:, 1), data(:, 2), data(:, 4))
