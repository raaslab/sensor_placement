% Spatio-temporal distribution estimation main

clc;
close all; clear all;

ST_Dis_Init;
ST_Dis_Sim_Init;

for k = 1:k_end
    ST_Dis_Update;
    ST_Dis_Plot;
    
    pause(0.5);
end