clc; clear all; close all;

% kernel hyperparameters are obtained by minimizing the negative marginal log likelihood of OM dataset
length_scale = exp(1.1341);
signal_std = exp(-1.3895);
noise_std = exp(-5.0313);	
N = 10000;

% confidence and accuracy parameters
epsilon = .25; delta = 0.8;

% r_max is obtained from lemma 1  
r_max = length_scale*sqrt(-log((signal_std^2+noise_std^2)/(N*signal_std^2)*(1-epsilon^2/(2*signal_std^2*erfinv(delta)^2))));


% lipschitz constant for underlying spatial field
lipschitz = 3;

% these values are chosen by observing the sampled functions for given kernel hyperparameters
a = 0.1; b = 0.1;
lipschitz_1 = 0.1;


% different values of alpha
alph = 125:1:250;


% denominatro in the expression for n_alpha
deno = epsilon - (lipschitz+sqrt(2)*lipschitz_1)*r_max./alph;


% final expression for n_alphaN
n_alph = (sqrt(2)*noise_std*erfinv(delta/(1-a*exp(-lipschitz_1^2/b^2)))./deno).^2-(noise_std/signal_std)^2;

plot(alph, n_alph);
grid on;
ylabel('log(n_{\alpha})')
xlabel('\alpha')
% function expression = myfun(n_alph)
% 	% xs = [0, 0];
% 	% theta = linspace(-pi, pi/2, 500)';
% 	% % theta = zeros(50, 1);
% 	% x = r_max*cos(theta); y = r_max*sin(theta); z = x.^2 + y.^2;	

% 	% x = gpml_randn(0.8, 20, 1)                 % 20 training inputs
% 	%   y = sin(3*x) + 0.1*gpml_randn(0.9, 20, 1);  % 20 noisy training targets
% 	%   xs = linspace(-3, 3, 61)';                  % 61 test inputs 	
% 	lipschitz = 3;
% 	a = 0.1; b = 0.1;
% 	lipschitz_1 = 5;
% 	epsilon = .075; delta = 0.9;
% 	length_scale = exp(1.1341);
% 	signal_std = exp(-1.3895);
% 	noise_std = exp(-5.0313); 	

% 	meanfunc = [];                    % empty: don't use a mean function
% 	covfunc = @covSEiso;              % Squared Exponental covariance function
% 	likfunc = @likGauss;              % Gaussian likelihood	
	

% 	hyp = struct('mean', [], 'cov', [log(length_scale) log(signal_std)], 'lik', log(noise_std));	

% 	% hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, x, y);	

% 	% [mu s2] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, [x, y], z, xs);	
% 	subexpression1 = sqrt(2)/sqrt(1/signal_std^2+n_alph/noise_std^2);
% 	subexpression2 = erfinv(delta/(1-a*exp(-lipschitz_1^2/b^2)))
% 	expression = (1/(lipschitz+sqrt(2)*lipschitz_1))*...
% 	(epsilon-subexpression1*subexpression2);	
	
% 	% f = [mu + 2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
% 	% fill([xs; flipdim(xs,1)], f, [7 7 7]/8)
% 	% hold on; plot(xs, mu); plot(x, y, '+')
% end