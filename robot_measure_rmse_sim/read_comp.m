function [num_comp, mean, cov, mean_var, cov_var] = read_comp

fpv = fopen('multi_comp.txt', 'r');
tmp.st = fscanf(fpv,'%s',1);
num_comp = fscanf(fpv,'%d',1);

for i = 1:num_comp
    tmp.st = fscanf(fpv,'%s',1);
    tmp.int = fscanf(fpv,'%d',1);
    tmp.st = fscanf(fpv,'%s',1);
    tmp.int = fscanf(fpv,'%d',2);
    sensors(i).Pos = [tmp.int(1), tmp.int(2)]';
    sensors(i).Pos(3) = 0;
    
    tmp.st = fscanf(fpv,'%s',1);
    tmp.int = fscanf(fpv,'%d',1);
    sensors(i).FoV = tmp.int(1);
end

fclose(fpv);

end