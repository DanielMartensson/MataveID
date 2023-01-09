clc; clear; close all;


N = 1000;
t = linspace(0, 100, N); % Time vector
e = randn(1, N); % Disturbance error
sampleTime = t(2) - t(1);
H = arma([1 -0.5 0.3],[1 -1.5 0.7], sampleTime); % Stochastic ARMA model
y = lsim(H, e, t); % Simulate the stochastic model
close
k = 20; % Hankel tuning block
systemorder = 2; % Second order, I assume
idH = sra(y, k, sampleTime, systemorder); % Identify stochastic model from output y
close
lsim(idH, e, t); % Simulate the identified model
hold on
plot(t, y); % Plot with real measurement