clc; clear; close all;

% Create inputs
N = 200;
u = linspace(1, 1, N);
u = [5*u 10*u -4*u 3*u 5*u 0*u -5*u 0*u];

% Create time
t = linspace(0, 100, length(u));

% Create second order model
G = tf(1, [1 0.8 3]);

% Simulate outputs
y = lsim(G, u, t);
close

% Add noise
e = 0.1*randn(1, length(u));
y = y + e;

% Do particle filtering - Tuning parameters
p = 4;                            % Length of the horizon (Change this)

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
plot(t, y, t, yf, '-r')
grid on
