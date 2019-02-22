function [temp] = actual_values(input_data, length_e, width_e)

std_dev = 0.8;
temp = [];

for g = 1 : size(input_data, 1)
	x = input_data(g, 1); y = input_data(g, 2);	

	if 2 <= x && x <= length_e && 0 <= y && y <= width_e
		mean_1 = [1, 3];
		mean_2 = [3, 1];
		mean_3 = [1, 1];
		mean_4 = [3, 3];
		% temp1 = 15;
		temp1 = 15 * exp((-([x, y] - mean_1) * ([x, y] - mean_1)')/std_dev) + 15 * exp((-([x, y] - mean_2) * ([x, y] - mean_2)')/std_dev);
		temp1 = temp1 + 15 * exp((-([x, y] - mean_3) * ([x, y] - mean_3)')/std_dev) + 15 * exp((-([x, y] - mean_4) * ([x, y] - mean_4)')/std_dev);
	else
		mean_1 = [1, 3];
		mean_2 = [3, 1];
		mean_3 = [1, 1];
		mean_4 = [3, 3];
		
		temp1 = 15 * exp((-([x, y] - mean_1) * ([x, y] - mean_1)')/std_dev) + 15 * exp((-([x, y] - mean_2) * ([x, y] - mean_2)')/std_dev);
		temp1 = temp1 + 15 * exp((-([x, y] - mean_3) * ([x, y] - mean_3)')/std_dev) + 15 * exp((-([x, y] - mean_4) * ([x, y] - mean_4)')/std_dev);
	end
	temp = [temp; temp1];
end
end

