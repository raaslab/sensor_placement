clear all; clc;
close all;

offset = 15; scaled = 20;

meanfunc = [];                    % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood


% 100 random points in square to collect observations
observe = load('sample_locations.txt'); 

% scatter(observe(:, 1), observe(:, 2));
% [X,Y] = meshgrid(x);
% values = offset + scaled*x.*exp(-x.^2-(y').^2);


% Select the point to include
fixed_point = [0, 0];

% Points for RMSE calculation
x = -2:0.05:2;
y = x;
[X, Y] = meshgrid(x);
xs = [X(:), Y(:)];
actual = offset + scaled*xs(:, 1).*exp(-xs(:, 1).^2 - xs(:, 2).^2);

num_trials = 10;
result_rmse = [];
result_prior = [];
for i = 1:num_trials
    observe_ = offset + scaled*observe(:, 1).*exp(-observe(:, 1).^2 - observe(:, 2).^2) + 0.5*randn(100, 1);
    
    error_prior = [];
    error_post = [];

    % Tuned hyper params by using 100 sampling points + [0,0]
    hyp = struct('mean', [], 'cov', [0 0], 'lik', -1);
    hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, [observe; 0, 0], [observe_; offset]);
%     hyp2.cov = [0.1392, 2.2655];
%     hyp2.lik = -0.7934;

    for subset_size = 1:size(observe_,1)
%         hyp = struct('mean', [], 'cov', [0 0], 'lik', -1);
%         hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, observe(1:subset_size, :), observe_(1:subset_size, :))
        [mu s2] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, [observe(1:subset_size, :);0, 0], [observe_(1:subset_size, :); offset], xs);
        error_post = [error_post; sqrt(mean((mu - actual).^2))];

        [mu s2] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, observe(1:subset_size, :), observe_(1:subset_size, :), xs);
        error_prior = [error_prior; sqrt(mean((mu - actual).^2))];
    end
    
    result_rmse(i,:) = (error_post-error_prior)';
    result_prior(i,:) = error_prior';
end

result_expected_rmse = sum(result_rmse)./num_trials;
result_monotonic_rmse = sum(result_prior)./num_trials;

figure(1)
plot(result_expected_rmse);

figure(2)
plot(result_monotonic_rmse);

% Submodularity
% figure(1)
% plot(1:size(observe_,1), abs(error_post - error_prior),'r');
% 
% figure(2)
% plot(error_post)
% fileID = fopen('ex10.txt', 'w');
% fprintf(fileID, '%f\n', abs(error_prior));

% mu = reshape(mu, size(X));

% figure(2);
% surf(x, y, mu);

% figure(2);
% scatter(observe(:, 1), observe(:, 2));