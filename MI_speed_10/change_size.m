initial_positions = [0 0; 1 1; 2 2; 3 2; 3 3];
window_sizes = [4.0 2.0 1.0 0.1]';

for index_position = 1 : size(initial_positions, 1)
	initial_position = initial_positions(index_position, :)
	for index_window = 1 : size(window_sizes, 1)
		window_size = window_sizes(index_window)


filename = ['plot_MI' '_' num2str(initial_position(1)) '_' num2str(initial_position(2)) '_'  'w' num2str(window_size)  '_r10' '.txt'];
% fileID = fopen(filename, 'w');
arr = load(filename);
% delete filename
mat_data = reshape(arr, [numel(arr)/2 ,2]);

% fprintf(fileID,'Window SIZE %d Initial %d %d \n', window_size, initial_position);
filename_new = ['plot_MI' '_' num2str(initial_position(1)) '_' num2str(initial_position(2)) '_'  'w' num2str(window_size)  '_r10' '.txt'];
fileID = fopen(filename_new, 'w');
fprintf(fileID,'%d \t %d\n', mat_data' );
end
end