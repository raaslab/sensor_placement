% Spatio-temporal distribution plot

figure(1)

axis([env_x(1) env_x(2) env_y(1) env_y(2)]);

for i = 1:num_comp
    mu(i,:) = comp.mean(:,i)';
    sigma(:,:,i) =  comp.cov(:,2*i-1:2*i);
    p(i) = comp.weight(i);
end

obj = gmdistribution(mu,sigma,p);

ezsurf(@(x,y)pdf(obj,[x y]),[env_x(1) env_x(2)],[env_y(1) env_y(2)])
title('Spatio-temporal distribution')