% reshape_x = 11;
% reshape_y = 11;

% subplot(2,1,1)
% val = load('learned_mean.txt');
% x = reshape(val(:, 1), [reshape_x reshape_y]);
% y =  reshape(val(:, 2), [reshape_x reshape_y]);
% value =  reshape(val(:, 3), [reshape_x reshape_y]);
% surf(x, y, value)
% view(2);
% colorbar;
% title('Value Function Mean')

% subplot(2,1,2)
% val = load('learned_var.txt');
% x = reshape(val(:, 1), [reshape_x reshape_y]);
% y =  reshape(val(:, 2), [reshape_x reshape_y]);
% value =  reshape(val(:, 3), [reshape_x reshape_y]);
% surf(x, y, value)
% view(2);
% colorbar;
% title('Variance')


% clear all;
% close all;

% val = load('hyperparam.txt');

% si = size(val, 1)-1;

% subplot(4,2,1)
% plot(80*(1:si),  100*abs(diff(val(:, 1)))./val(1:end-1,1), '-o')
% title('Signal Variance')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')


% subplot(4,2,2)
% plot(80*(1:si),100*abs(diff(val(:, 2)))./val(1:end-1, 2), '-o')
% title('first laser reading length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(4,2,3)
% plot(80*(1:si),100*abs(diff(val(:, 3)))./val(1:end-1, 3), '-o')
% title('second laser reading length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(4,2,4)
% plot(80*(1:si),100*abs(diff(val(:, 4)))./val(1:end-1, 4), '-o')
% title('third laser reading length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(4,2,5)
% plot(80*(1:si),100*abs(diff(val(:, 5)))./val(1:end-1, 5), '-o')
% title('fourth laser reading length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')


% subplot(4,2,6)
% plot(80*(1:si),100*abs(diff(val(:, 6)))./val(1:end-1, 6), '-o')
% title('action length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(4,2,7)
% plot(80*(1:si),100*abs(diff(val(:, 7)))./val(1:end-1, 7), '-o')
% title('Noise variance')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')


% b = [.175 .26 .322 .321 .34 .325 .37 .425 .44];
% r = [.07 .19 .225 .225 .25 .27 .295 .365 .35];
% v = [.07 .09 .13 .155 .155 .175 0.19 .21 .23];
% y = [.05 .06 .09 .08 .1 .105 .16 .175 .22];

% err = 0.02 * randn(9, 1);
% errorbar(.1:.05:.5, v, err); 
% hold on;

% err = 0.02 * randn(9, 1);
% errorbar(.1:.05:.5, y, err); 
% hold on;

% err = 0.02 * randn(9, 1);
% errorbar(.1:.05:.5, r, err);
% hold on; 

% err = 0.02 * randn(9, 1);
% errorbar(.1:.05:.5, b, err),
x = [.5 1.5 1.5 .5]; y = [0 0 100 100]; 
fill(x, y, 'b')
hold on;

x = [2.5 3.5 3.5 2.5]; y = [100 100 120 120]; 
fill(x, y, 'b')
hold on;

x = [.5 1.5 1.5 .5]; y = [120 120 200 200]; 
fill(x, y, 'b')
hold on;

x = [2.5 3.5 3.5 2.5]; y = [200 200 230 230]; 
fill(x, y, 'b')
hold on;

x = [.5 1.5 1.5 .5]; y = [230 230 275 275]; 
fill(x, y, 'b')
hold on;

x = [2.5 3.5 3.5 2.5]; y = [275 275 300 300]; 
fill(x, y, 'b')
hold on;

x = [.5 1.5 1.5 .5]; y = [300 300 320 320]; 
fill(x, y, 'b')
hold on;

x = [2.5 3.5 3.5 2.5]; y = [320 320 360 360]; 
fill(x, y, 'b')

axis([0, 4, 0, inf])