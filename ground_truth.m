clear all;
clc;
close all;

load('OM_dataset.mat');
Xq = flipud(Xq);
Yq = flipud(Yq);
Zq = flipud(Zq)-10;


meanfunc = @meanConst;                    % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood

hyp = struct('mean', [3.9066], 'cov', [1.1341 -1.3895], 'lik', -5.0313);

environment = [135, 230, 230, 190, 190, 140, 80, 150; 20, 20, 60, 70, 115, 115, 50, 50];

% figure();
% patch(environment(1, :), environment(2, :), 'red');
% hold on;
% axis equal;

%% define the farm boundary
in = double(inpolygon(Xq, Yq, environment(1, :), environment(2, :)));
ex_polygon = in == 0;
Xq(ex_polygon) = nan; Yq(ex_polygon) = nan; Zq(ex_polygon) = nan;

inputDesign = [Xq(:), Yq(:), Zq(:)];

inputDesign(any(isnan(inputDesign), 2), :) = [];
% Xq = Xq(min(environment(1, :)):max(environment(1, :)), min(environment(2, :)):max(environment(2, :)));
% Yq = Yq(min(environment(1, :)):max(environment(1, :)), min(environment(2, :)):max(environment(2, :)));
% Zq = Zq(min(environment(1, :)):max(environment(1, :)), min(environment(2, :)):max(environment(2, :)));

% hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, inputDesign(1:10:end, 1:2), inputDesign(1:10:end, end));
% define lipschitz constant (ppm/meter)
lipschitz = 3;
l = exp(1.1341); sigma_0 = exp(-1.3895); omega = exp(-5.0313);
N = 100;
epsilon = .05; delta = 0.5795;
arg1 = (sigma_0^2+omega^2)/(N*sigma_0^2);
arg2 = 1-epsilon/(sqrt(2)*sigma_0^2*erfinv(delta));
% r_max = l*sqrt(-log(arg1*arg2));
r_max = 20;


% Covering disks
[diskX, diskY] = meshgrid(min(environment(1, :)):r_max:max(environment(1, :)), min(environment(2, :)):r_max:max(environment(2, :)));

points = [diskX(:), diskY(:)];
new = size(points, 1);
i = 1;
% pause();
% Calculate MIS and denote centers of MIS disks by 'points'
while i < new
	index_c = [];
	for j = i + 1 : size(points, 1)
		if (points(i, 1) - points(j, 1))^2 + (points(i, 2) - points(j, 2))^2 <= 4*r_max^2
			index_c = [index_c; j];
		end
	end
	for len = size(index_c, 1) : -1 : 1
		points(index_c(len, 1), :) = [];
	end
	new = size(points, 1);
	i = i + 1;
end

% delete first two disks from bar{X} (they lie completely out of the environment)
points = points(3:end, :);
measurement_locations = [];
% Cover with r_max/2 radii disks
for i = 1:size(points, 1)
	[tmp_measurement_locationsX, tmp_measurement_locationsY] = meshgrid(points(i, 1)-3*r_max:r_max/sqrt(2):points(i, 1)+3*r_max,...
	 points(i, 2)-3*r_max:r_max/sqrt(2):points(i, 2)+3*r_max);
	measurement_locations = [measurement_locations; [tmp_measurement_locationsX(:), tmp_measurement_locationsY(:)]];
end


figure();
h = surf(Xq, Yq, Zq);
hold on;
% scatter(diskX(:), diskY(:));
set(h,'LineStyle','none')
axis equal; grid off;
viscircles([points(:, 1), points(:, 2)], 3*r_max*ones(size(points, 1), 1));
% viscircles([tmp_measurement_locationsX(:), tmp_measurement_locationsY(:)], 0.5*r_max*ones(numel(tmp_measurement_locationsX(:)), 1));