clear all;
clc; close all;

meanfunc = [];                    % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood


offset = 15; scaled = 20;
% measure time in seconds
measure_time = 30;

arr = [];

hyp2.cov = [0.0610, 5.2878];
hyp2.lik = -10.7934;


% total budget
budget = 50;

for speed = .1:.01:1.5
	% specify total budget in seconds
	% find the points robot can visit 
	x = -2:16/((budget-measure_time)*speed):2;
	y = x;
	[X, Y] = meshgrid(x);
	observe = [X(:), Y(:)];
	observe_ = offset + scaled*observe(:, 1).*exp(-observe(:, 1).^2 - observe(:, 2).^2);	

	% testLoc = load('sample_locations.txt');
	testLoc = 4*rand(200, 2) - 2;
	testLoc_ = offset + scaled*testLoc(:, 1).*exp(-testLoc(:, 1).^2 - testLoc(:, 2).^2);	
	

	hyp = struct('mean', [], 'cov', [0 0], 'lik', -1);
	% hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, observe, observe_)
	[mu s2] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, observe, observe_, testLoc);
	arr = [arr; sqrt(sum((mu-testLoc_).^2)/100)];
end

plot(.1:.01:1.5, arr);
axis([.1 1.5 0 12]);
fileID = fopen('measure3.txt', 'w');
fprintf(fileID, '%f\n', arr);