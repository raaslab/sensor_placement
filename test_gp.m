x = linspace(-4, 4, 100)';               
y = sin(3*x) + normrnd(x, 0.2);  
xs = linspace(-4, 4, 61)';         

% x = gpml_randn(0.8, 20, 1)                 % 20 training inputs
%   y = sin(3*x) + 0.1*gpml_randn(0.9, 20, 1);  % 20 noisy training targets
%   xs = linspace(-3, 3, 61)';                  % 61 test inputs 

length_scale = 10;
signal_std = 10;
noise_std = 0.2; 

meanfunc = [];                    % empty: don't use a mean function
covfunc = @covSEiso;              % Squared Exponental covariance function
likfunc = @likGauss;              % Gaussian likelihood


hyp = struct('mean', [], 'cov', [log(length_scale) log(signal_std)], 'lik', log(noise_std));

% hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, x, y);

[mu s2] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs);


f = [mu + 2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
fill([xs; flipdim(xs,1)], f, [7 7 7]/8)
hold on; plot(xs, mu); plot(x, y, '+')

