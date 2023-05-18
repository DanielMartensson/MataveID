clc; clear; close all;

% Load CSV data
file = fullfile('..','data','MotorRotation.csv');
X = csvread(file); % Can be found in the folder "data"
t = X(:, 1);
u = X(:, 2);
y = X(:, 3);
sampleTime = 0.02;

% Do filtering of y
y = mi.filtfilt(y', t', 0.1)';

% Sindy - Sparce identification Dynamics
degree = 5;
lambda = 0.05;
l = length(u);
h = floor(l/2);
s = ceil(l/2);
fx_up = mi.sindy(u(1:h), y(1:h), degree, lambda, sampleTime); % We go up
fx_down = mi.sindy(u(s:end), y(s:end), degree, lambda, sampleTime); % We go down

% Simulation up
x0 = y(1);
u_up = u(1:h);
u_up = u_up(1:100:end)';
stepTime = 1.2;
[x_up, t] = mc.nlsim(fx_up, u_up, x0, stepTime, 'ode15s');

% Simulation down
x0 = y(s);
u_down = u(s:end);
u_down = u_down(1:100:end)';
stepTime = 1.2;
[x_down, t] = mc.nlsim(fx_down, u_down, x0, stepTime, 'ode15s');

% Compare
figure
plot([x_up x_down])
hold on
plot(y(1:100:end));
legend('Simulation', 'Measurement')
ylabel('Rotation')
xlabel('Time')
grid on
