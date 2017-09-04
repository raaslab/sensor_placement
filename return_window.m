function [returned_window] = return_window(mat, l)
	returned_window1 = [];
	for x = mat(1,1) - l : 0.1 : mat(1,1) + l
		for y = mat(1, 2) - l : 0.1 : mat(1, 2) + l
			if x >=0 && x<=4 && y>=0 && y<=4
				returned_window1 = [returned_window1; [x , y]];
			end
		end
	end
	returned_window = returned_window1; 
end

