import_adaptive = load('plot_adaptive.txt');
import_non_adaptive = load('plot_non_adaptive.txt');

plot(import_adaptive(1 : length(import_adaptive)/2),import_adaptive(length(import_adaptive)/2 + 1 : end))
hold on;
plot(import_non_adaptive(1 : length(import_non_adaptive)/2),import_non_adaptive(length(import_non_adaptive)/2 + 1 : end));