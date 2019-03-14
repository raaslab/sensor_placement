clear all;
close all;

r_max = 8.5;
alph = 100;

n_alph_var = 10:100:10000;
val = [];
for n_alph = n_alph_var
	val = [val, myfun(n_alph)];
end

plot(n_alph_var, val, 'red')
hold on;
line([n_alph_var(1), n_alph_var(end)], [r_max/alph, r_max/alph]);

function expression = myfun(n_alph)
	% xs = [0, 0];
	% theta = linspace(-pi, pi/2, 500)';
	% % theta = zeros(50, 1);
	% x = r_max*cos(theta); y = r_max*sin(theta); z = x.^2 + y.^2;	

	% x = gpml_randn(0.8, 20, 1)                 % 20 training inputs
	%   y = sin(3*x) + 0.1*gpml_randn(0.9, 20, 1);  % 20 noisy training targets
	%   xs = linspace(-3, 3, 61)';                  % 61 test inputs 	
	lipschitz = 3;
	a = 0.1; b = 0.1;
	lipschitz_1 = 5;
	epsilon = .075; delta = 0.9;
	length_scale = exp(1.1341);
	signal_std = exp(-1.3895);
	noise_std = exp(-5.0313); 	

	meanfunc = [];                    % empty: don't use a mean function
	covfunc = @covSEiso;              % Squared Exponental covariance function
	likfunc = @likGauss;              % Gaussian likelihood	
	

	hyp = struct('mean', [], 'cov', [log(length_scale) log(signal_std)], 'lik', log(noise_std));	

	% hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, x, y);	

	% [mu s2] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, [x, y], z, xs);	
	subexpression1 = sqrt(2)/sqrt(1/signal_std^2+n_alph/noise_std^2);
	subexpression2 = erfinv(delta/(1-a*exp(-lipschitz_1^2/b^2)))
	expression = (1/(lipschitz+sqrt(2)*lipschitz_1))*...
	(epsilon-subexpression1*subexpression2);	
	% f = [mu + 2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
	% fill([xs; flipdim(xs,1)], f, [7 7 7]/8)
	% hold on; plot(xs, mu); plot(x, y, '+')
end