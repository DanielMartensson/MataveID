clc; clear; close all;

X = dlmread('..\data\ParticleFilterDataRaw.csv',';',1,0);
t = X(:, 1)';
y = X(:, 2)';

% Do particle filtering - Tuning parameters
p = 14;                            % Length of the horizon (Change this)

% Particle filter - No tuning
[m, n] = size(y);                  % Dimension of the output state and length n
yf = zeros(m, n);                  % Filtered outputs
horizon = zeros(m, p);             % Horizon matrix
xhatp = zeros(m, 1);               % Past estimated state
k = 1;                             % Horizon counting (will be counted to p. Do not change this)
noise = rand(m, p);                % Random noise, not normal distributed

% Particle filter - Simulation
for i = 1:n
  x = y(:, i);                     % Get the state
  [xhat, horizon, k, noise] = pf(x, xhatp, k, horizon, noise);
  yf(:, i) = xhat;                 % Estimated state
  xhatp = xhat;                    % This is the past estimated state
end

% Plot restult
plot(t, y)
hold on
plot(t, yf, '-r')
grid on