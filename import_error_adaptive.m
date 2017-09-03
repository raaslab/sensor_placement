error1_a = load('error1_adaptive.txt');
error2_a = load('error2_adaptive.txt');
error3_a = load('error3_adaptive.txt');
error4_a = load('error4_adaptive.txt');
error5_a = load('error5_adaptive.txt');
error6_a = load('error6_adaptive.txt');
error7_a = load('error7_adaptive.txt');
error8_a = load('error8_adaptive.txt');
error9_a = load('error9_adaptive.txt');
error10_a = load('error10_adaptive.txt');
error11_a = load('error11_adaptive.txt');
error12_a = load('error12_adaptive.txt');
% error13_a = load('error13.txt');
% error14_a = load('error14.txt');
% error15_a = load('error15.txt');
% error16_a = load('error16.txt');
% error17_a = load('error17.txt');
% error18_a = load('error18.txt');
% error19_a = load('error19.txt');
% error20_a = load('error20.txt');

error_matrix = [];

error_mat_a = [41.65 size(find(error1_a > 15),1);
75.24 size(find(error2_a > 15),1);
103.50 size(find(error3_a > 15),1);
166.61 size(find(error4_a > 15),1);
232.55 size(find(error5_a > 15),1);
319.77 size(find(error6_a > 15),1);
444.30 size(find(error7_a > 15),1);
586.79 size(find(error8_a > 15),1);
736.86 size(find(error9_a > 15),1);
827.54 size(find(error10_a > 15),1);
1092.7 size(find(error11_a > 15),1);
1346 size(find(error12_a > 15),1)];


% error_matrix(:, :, 1) = error1;
% error_matrix(:, :, 2) = error2;
% error_matrix(:, :, 3) = error3;
% error_matrix(:, :, 4) = error4;
% error_matrix(:, :, 5) = error5;
% error_matrix(:, :, 6) = error6;
% error_matrix(:, :, 7) = error7;
% error_matrix(:, :, 8) = error8;
% error_matrix(:, :, 9) = error9;
% error_matrix(:, :, 10) = error10;
% error_matrix(:, :, 11) = error11;
% error_matrix(:, :, 12) = error12;
% error_matrix(:, :, 13) = error13;
% error_matrix(:, :, 14) = error14;
% error_matrix(:, :, 15) = error15;
% error_matrix(:, :, 16) = error16;
% error_matrix(:, :, 17) = error17;
% error_matrix(:, :, 18) = error18;
% error_matrix(:, :, 19) = error19;
% error_matrix(:, :, 20) = error20;


plot(error_mat_a(: , 1), 200 * error_mat_a(: , 2)/1681);

hold on;

dist_offline = [179.59 235.06 270 361 415.72 451.35 504.12 541.85 614.55];
number_of_miss = [861 596 594 319 145 157 95 95 71];

plot(dist_offline, 100 * number_of_miss/1681);

% surf(X_pred, Y_pred,  5 * sum(abs(error_matrix) > 100 * 0.35 * epsilon/max_diff, 3));