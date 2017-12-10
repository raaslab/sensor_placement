clear all;
clc;
close all;

offset = 15; scaled = 20;

meanfunc = [];                    % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood

% 100 random points in square to collect observations
observe = 4*rand(100, 2) - 2; 
observe_ = offset + scaled*observe(:, 1).*exp(-observe(:, 1).^2 - observe(:, 2).^2);

scatter(observe(:, 1), observe(:, 2));

% [X,Y] = meshgrid(x);
% values = offset + scaled*x.*exp(-x.^2-(y').^2);



% Select the point to include
fixed_point = [0, 0];

% Points for RMSE calculation
x = -2:0.1:2;
y = x;
[X, Y] = meshgrid(x);
xs = [X(:), Y(:)];
actual = offset + scaled*xs(:, 1).*exp(-xs(:, 1).^2 - xs(:, 2).^2);

error_prior = [];
error_post = [];

for subset_size = 1:100
	hyp = struct('mean', [], 'cov', [0 0], 'lik', -1);
	%hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, observe(1:subset_size, :), observe_(1:subset_size, :))
	[mu s2] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, observe(1:subset_size, :), observe_(1:subset_size, :), xs);
	error_prior = [error_prior; sum(sum(abs(mu - actual).^2))];
end

for subset_size = 1:100
	hyp = struct('mean', [], 'cov', [0 0], 'lik', -1);
	%hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, [observe(1:subset_size, :); 0, 0], [observe_(1:subset_size, :); offset])
	[mu s2] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, [observe(1:subset_size, :);0, 0], [observe_(1:subset_size, :); offset], xs);
	error_post = [error_post; sum(sum(abs(mu - actual).^2))];
end



% mu = reshape(mu, size(X));

% figure(1);
% surf(x, y, mu);




% figure(2);
% scatter(observe(:, 1), observe(:, 2));
