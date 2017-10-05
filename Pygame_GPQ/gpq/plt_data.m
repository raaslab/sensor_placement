clear all;
clc;

data = load('record.txt');
scatter3(data(:, 1), data(:, 2), data(:, 3))
