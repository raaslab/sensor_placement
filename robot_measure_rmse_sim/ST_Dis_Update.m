% Spatio-temporal distribution update

for i = 1:num_comp
    cur_mean = comp.mean(:,i);
    cur_cov = comp.cov(:,2*i-1:2*i);
    cur_mean_var = comp.mean_var(:,i);
    cur_cov_var = comp.cov_var(:,i);
    
    cur_mean = [cur_mean(1)+cur_mean_var(1); cur_mean(2)+cur_mean_var(2)];
    cur_cov = [cur_cov(1,1)+cur_cov_var(1) cur_cov(1,2);
                cur_cov(2,1) cur_cov(2,2)+cur_cov_var(2)];
    comp.mean(:,i) = cur_mean;
    comp.cov(:,2*i-1:2*i) = cur_cov;
end
