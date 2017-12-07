function [num_comp, r_comp] = read_comp

fpv = fopen('multi_comp.txt', 'r');
tmp.st = fscanf(fpv,'%s',1);
num_comp = fscanf(fpv,'%d',1);

r_comp.mean = [];
r_comp.cov = [];
r_comp.mean_var = [];
r_comp.cov_var = [];

for i = 1:num_comp
    tmp.st = fscanf(fpv,'%s',1);
    tmp.int = fscanf(fpv,'%d',1);
    tmp.st = fscanf(fpv,'%s',1);
    tmp.int = fscanf(fpv,'%d',2);
    r_comp.mean(:,i) = [tmp.int(1), tmp.int(2)]';
    
    tmp.st = fscanf(fpv,'%s',1);
    tmp.int = fscanf(fpv,'%d',4);
    r_comp.cov(:,2*i-1:2*i) = [tmp.int(1), tmp.int(2); tmp.int(3), tmp.int(4)];
    
    tmp.st = fscanf(fpv,'%s',1);
    tmp.int = fscanf(fpv,'%d',2);
    r_comp.mean_var(:,i) = [tmp.int(1), tmp.int(2)]';
    
    tmp.st = fscanf(fpv,'%s',1);
    tmp.int = fscanf(fpv,'%f',2);
    r_comp.cov_var(:,i) = [tmp.int(1), tmp.int(2)]';
end

fclose(fpv);

end