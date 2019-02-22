clear all;
close all;

c = 2;
omega = 50;
epsilon = 5;
l1 = 1;
l = 5;
prior = 10;
ratio = 1.01:.1:10;
n = (c*omega./(epsilon - (1./ratio)*(epsilon + c*omega)*(1 + l1/l))).^2 - (omega/prior)^2;
approx = 18*ratio.^2.*n;
plot(ratio, approx);