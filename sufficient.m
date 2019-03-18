length_scale = exp(1.1341);
signal_std = exp(-1.3895);
noise_std = exp(-5.0313); 	
lipschitz = 3;
lipschitz_1 = 5;
epsilon = 0.25; delta = 0.8;
a= 0.1; b = 0.1;
n = 1:10:7000;
subexpression1 = sqrt(2)./sqrt(1/signal_std^2+n/noise_std^2);
subexpression2 = erfinv(delta/(1-a*exp(-lipschitz_1^2/b^2)));
expression = (1/(lipschitz+sqrt(2)*lipschitz_1))*(epsilon-subexpression1*subexpression2);	

plot(n, expression, 'Linewidth', 2);
xlabel('n_{\alpha}'); ylabel('RHS in Eq 20');