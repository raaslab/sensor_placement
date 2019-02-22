clear all;
clc;
close all;

load('OM_dataset.mat');
Xq = flipud(Xq);
Yq = flipud(Yq);
Zq = flipud(Zq);

environment = [135, 230, 230, 190, 190, 140, 80, 150; 20, 20, 60, 70, 115, 115, 50, 50];

% figure();
% patch(environment(1, :), environment(2, :), 'red');
% hold on;
% axis equal;

in = double(inpolygon(Xq, Yq, environment(1, :), environment(2, :)));
ex_polygon = in == 0;

Xq(ex_polygon) = nan; Yq(ex_polygon) = nan; Zq(ex_polygon) = nan;

% figure();
% h = surf(Xq, Yq, Zq);
% set(h,'LineStyle','none')
% axis equal; grid off;