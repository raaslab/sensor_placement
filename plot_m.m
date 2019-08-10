clear all;
clc;
close all;


prior_variance = 10;
omega = 1;
MSE = 1;

alpha_ = 1.1:0.05:2;

den = (1-MSE/prior_variance^2).^(1./alpha_.^2-1)-1;
expression = alpha_.^2*(omega/prior_variance)^2./den;

plot(alpha_, expression);
xlabel('\alpha')
% ylabel('Total measurements required to cover the bigger disk')