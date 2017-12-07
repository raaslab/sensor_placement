% Spatio-temporal distribution simulation initialization

comp.mean = [];
comp.cov = [];
comp.mean_var = [];
comp.cov_var = [];

[num_comp, comp] = read_comp;

for i = 1:num_comp
    comp.weight(i) = 1/num_comp;
end