clc; clear; close all;
% Load the data
file = fullfile('..','data','MultivariableCylinders.csv');
X = csvread(file);
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
ktune = 0.01; % Kalman filter tuning
% This won't result well with MOESP and system order = 2
[sysd, K] = mi.n4sid(u, y, k, sampleTime, ktune); % Delay argment is default 0. Select model order = 2 when n4sid ask you

% Create the observer
observer = mc.ss(sysd.delay, sysd.A - K*sysd.C, [sysd.B K], sysd.C, [sysd.D sysd.D*0]);
observer.sampleTime = sysd.sampleTime;

% Do simulation
[outputs, T, x] = mc.lsim(observer, [u; y], t);
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
