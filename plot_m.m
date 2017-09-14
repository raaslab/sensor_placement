clear all;
clc;


epsilon = 0.2;
delta = 0.8;

omega = 2.0 : 0.05 : 3;


for index_omega = 1 : numel(omega)
	zeta = (2 *  epsilon^2 * omega(index_omega)^2) / log(2/delta);
	num_m = (zeta - 1) * omega (index_omega)^ 2;
	rho = sqrt(1  - 0.95 * zeta) : 0.05 * zeta : 1; 
	for index_rho = 1 : numel(rho)
		den_m = 1 - rho(index_rho) ^ 2 - zeta;		
		plot3(omega(index_omega), rho(index_rho), num_m/den_m);
		hold on;
	end
end


xlabel('omega');
ylabel('rho');