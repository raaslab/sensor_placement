val = load('learned.txt');
x = reshape(val(:, 1), [20 26]);
y =  reshape(val(:, 2), [20 26]);
value =  reshape(val(:, 3), [20 26]);
surf(x, y, value)
view(2);
colorbar;
title('Value Function')
% clear all;
% close all;

% val = load('hyperparam.txt');

% si = size(val, 1)-1;

% subplot(6,2,1)
% plot(80*(1:si),  100*abs(diff(val(:, 1)))./val(1:end-1,1), '-o')
% title('Signal Variance')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')


% subplot(6,2,2)
% plot(80*(1:si),100*abs(diff(val(:, 2)))./val(1:end-1,2), '-o')
% title('robot x-coordinate length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(6,2,3)
% plot(80*(1:si),100*abs(diff(val(:, 3)))./val(1:end-1,3), '-o')
% title('robot y-coordinate length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(6,2,4)
% plot(80*(1:si),100*abs(diff(val(:, 4)))./val(1:end-1,4), '-o')
% title('robot orientation X-component length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(6,2,5)
% plot(80*(1:si),100*abs(diff(val(:, 5)))./val(1:end-1,5), '-o')
% title('robot orientation Y-component length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(6,2,6)
% plot(80*(1:si),100*abs(diff(val(:, 6)))./val(1:end-1,6), '-o')
% title('first laser reading length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(6,2,7)
% plot(80*(1:si),100*abs(diff(val(:, 7)))./val(1:end-1,7), '-o')
% title('second laser reading length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(6,2,8)
% plot(80*(1:si),100*abs(diff(val(:, 8)))./val(1:end-1,8), '-o')
% title('third laser reading length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(6,2,9)
% plot(80*(1:si),100*abs(diff(val(:, 9)))./val(1:end-1,9), '-o')
% title('fourth laser reading length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')


% subplot(6,2,10)
% plot(80*(1:si),100*abs(diff(val(:, 10)))./val(1:end-1, 10), '-o')
% title('action length scale')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')

% subplot(6,2,11)
% plot(80*(1:si),100*abs(diff(val(:, 11)))./val(1:end-1, 11), '-o')
% title('Noise variance')
% xlabel('Number of timesteps')
% %ylabel('% change with respect to previous timestep')
