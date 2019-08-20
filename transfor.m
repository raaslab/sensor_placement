close all;
% old = load('lat_lan.txt');
% new = old(1:2, :);

% old(1:3, :) = [];


% while ~isempty(old)
% for index = 1:size(old, 1)
% 	if 	isequal(new(end, :), old(index, :)) 
% 		if rem(index, 3) == 1
% 			new = [new; old(index + 1, :)];
% 			old(index: index + 2, :) = [];
% 			break;
% 		else
% 			new = [new; old(index - 1, :)];
% 			old(index - 1: index + 1, :) = [];
% 			break;
% 		end
% 	end
% end
% new
% end

lat_lan = load('modified_lat_lan.txt');

plt = plot([environment(1, :), environment(1, 1)], [environment(2, :), environment(2, 1)]);
plt.Color = 'black'

hold on;

plot([lat_lan(1:16, 1); lat_lan(1, 1)], [lat_lan(1:16, 2); lat_lan(1, 2)], 'r');
plot([lat_lan(1, 1);lat_lan(17:35, 1);lat_lan(1, 1)], [lat_lan(1, 2);lat_lan(17:35, 2);lat_lan(1, 2)], 'g');
plot([lat_lan(36:end, 1); lat_lan(36, 1)], [lat_lan(36:end, 2); lat_lan(36, 2)], 'b');