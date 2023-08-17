% Clear
close all
clear all
clc

% Logistic data
x = [-0.1, -0.2, -0.3, -0.311, -0.213, -0.133, -0.231, -0.4215, 0.13, 0.23, 0.19, 0.9, 1.2, 1.5, 0.423, 0.561];
y = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1];

% Create the parameters a and b for tanh
[a, b, flag, iterations] = mi.logreg(x, y, 'tanh');

% Plot the logistic function: tanh
t = linspace(-10, 10, 1000);
p = (exp(a*t + b) - exp(-a*t - b))./(exp(a*t + b) + exp(-a*t - b));
plot(t, p)
title('tanh function', 'FontSize', 20)
grid on

% Create the parameters a and b for sigmoid
[a, b, flag, iterations] = mi.logreg(x, y, 'sigmoid');

% Plot the logistic function: sigmoid
t = linspace(min(x), max(x), 1000);
p = 1./(1 + exp(-(a*t + b)));
figure
plot(t, p)
title('sigmoid function', 'FontSize', 20)
grid on
