% x = linspace(-4, 4, 100)';
% y = sin(3*x) + normrnd(x, 0.2);  
clc;
clear all;
close all;
epsilon = 2.5; delta = 0.8;

r_max_var = .1:.1:15;
val = [];
for r_max = r_max_var
	val = [val, myfun(r_max)];
end

plot(r_max_var, val, 'red');
hold on;
line([r_max_var(1), r_max_var(end)], [epsilon^2/(2*erfinv(delta)^2), epsilon^2/(2*erfinv(delta)^2)]);

function expression = myfun(r_max)
	xs = [0, 0];
	theta = linspace(-pi, pi/2, 10000)';
	% theta = zeros(50, 1);
	x = r_max*cos(theta); y = r_max*sin(theta); z = x.^2 + y.^2;	

	% x = gpml_randn(0.8, 20, 1)                 % 20 training inputs
	%   y = sin(3*x) + 0.1*gpml_randn(0.9, 20, 1);  % 20 noisy training targets
	%   xs = linspace(-3, 3, 61)';                  % 61 test inputs 	

	length_scale = exp(-1.1341);
	signal_std = exp(1.3895);
	noise_std = exp(-5.0313); 	

	meanfunc = [];                    % empty: don't use a mean function
	covfunc = @covSEiso;              % Squared Exponental covariance function
	likfunc = @likGauss;              % Gaussian likelihood	
	

	% hyp = struct('mean', [], 'cov', [log(length_scale) log(signal_std)], 'lik', log(noise_std));	

	% hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, x, y);	

	% [mu s2] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, [x, y], z, xs);	

	expression = signal_std^2*(1-exp(-r_max^2/length_scale^2)*numel(theta)*signal_std^2/...
		(signal_std^2+noise_std^2));	
	% f = [mu + 2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
	% fill([xs; flipdim(xs,1)], f, [7 7 7]/8)
	% hold on; plot(xs, mu); plot(x, y, '+')
end