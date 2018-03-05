clc; clear all;
close all;

ex1 = sqrt(load('ex1.txt')/6561);
ex2 = sqrt(load('ex2.txt')/6561);
ex3 = sqrt(load('ex3.txt')/6561); 
ex4 = sqrt(load('ex4.txt')/6561);
ex5 = sqrt(load('ex5.txt')/6561);
ex6 = sqrt(load('ex6.txt')/6561);
ex7 = sqrt(load('ex7.txt')/6561);
ex8 = sqrt(load('ex8.txt')/6561);
ex9 = sqrt(load('ex9.txt')/6561);
ex10 = sqrt(load('ex10.txt')/6561);

plot((ex1 + ex2 + ex3 + ex4 + ex5 + ex6 + ex7 + ex8 + ex9 + ex10)/10);
ylabel('marginal gain in expected rmse');
xlabel('size of subset');