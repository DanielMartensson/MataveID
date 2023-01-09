clc; clear; close all;
% Load the data
X = csvread('..\data\MultivariableCylinders.csv');
t = X(:, 1);
r0 = X(:, 2);
r1 = X(:, 3);
y0 = X(:, 4);
y1 = X(:, 5);
sampleTime = 0.1;

% Transpose the CSV data
u = [r0';r1'];
y = [y0';y1'];
t = t';

% Create the model
k = 10;
sampleTime = t(2) - t(1);
% This won't result well with MOESP and system order = 2
[sysd] = n4sid(u, y, k, sampleTime); % Delay argment is default 0. Select model order = 2 when n4sid ask you

% Do simulation
[outputs, T, x] = lsim(sysd, y, t);
close
plot(T, outputs(1, :), t, y(1, :))
title('Cylinder 0');
xlabel('Time');
ylabel('Position');
grid on
legend('Identified', 'Measured');
ylim([0 12]);
figure
plot(T, outputs(2, :), t, y(2, :))
title('Cylinder 1');
xlabel('Time');
ylabel('Position');
grid on
legend('Identified', 'Measured');
ylim([0 12]);