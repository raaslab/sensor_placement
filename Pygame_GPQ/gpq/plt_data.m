reshape_x = 11;
reshape_y = 11;

subplot(2,1,1)
val = load('learned_mean.txt');
x = reshape(val(:, 1), [reshape_x reshape_y]);
y =  reshape(val(:, 2), [reshape_x reshape_y]);
value =  reshape(val(:, 3), [reshape_x reshape_y]);
surf(x, y, value)
view(2);
colorbar;
title('Value Function Mean')

subplot(2,1,2)
val = load('learned_var.txt');
x = reshape(val(:, 1), [reshape_x reshape_y]);
y =  reshape(val(:, 2), [reshape_x reshape_y]);
value =  reshape(val(:, 3), [reshape_x reshape_y]);
surf(x, y, value)
view(2);
colorbar;
title('Variance')


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
