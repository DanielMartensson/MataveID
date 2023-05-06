% Clear all
clear all
clc

% Create data. You can have multiple columns and multiple rows.
x = [-5 -2;
     -1 -4;
     -3 -1;
     -7 -2;
     -8 -1;
     -9 -3;
     -2, -6;
     -8, -5;
     -1, -1;
     -2, -9;
     -3, 0;
     -2, -5;
     -2, -8;
     50 20;
     10 40;
     30 10;
     70 20;
     80 10;
     90 30;
     20, 60;
     80, 50;
     10, 10;
     20, 90;
     30, 0;
     20, 50;
     20, 80];

% Create labels for the data x
y = [1;1;1;1;1;1;1;1;1;1;1;1;1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1];

% Tuning parameters
C = 1;              % For upper boundary limit
lambda = 10;        % Regularization (Makes it faster to solve the quadratic programming)

% Compute weigths, bias and find accuracy
[w, b, accuracy] = lsvm(x, y, C, lambda)
