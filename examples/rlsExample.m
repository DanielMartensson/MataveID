% Load data
X = csvread('..\data\HangingLoad.csv');
t = X(:, 1)'; % Time
r = X(:, 2)'; % Reference
y = X(:, 3)'; % Output position
u = X(:, 4)'; % Input signal from P-controller with gain 3
sampleTime = 0.02;

% Do identification of the first data set
l = length(r) + 2000; % This is half data

% Poles and zeros
np = 1; % Number of poles for A(q)
nz = 1; % Number of zeros of B(q)
nze = 1; % Number of zeros of C(q)

% Model up
u_up = r(1:l/2);
e_up = randn(1, length(u_up)); % Noise
y_up = y(1:l/2) + e_up;
[sysd, K] = rls(u_up, y_up, np, nz, nze, sampleTime);

% Observer
sysd_up = mc.ss(0, sysd.A - K*sysd.C, [sysd.B K], sysd.C, [sysd.D 0]);
sysd_up.sampleTime = sysd.sampleTime;

% Model down
u_down = r(l/2+1:end);
e_down = randn(1, length(u_down)); % Noise
y_down = y(l/2+1:end) + e_down;
[sysd, K] = rls(u_down, y_down, np, nz, nze, sampleTime);

% Observer
sysd_down = mc.ss(0, sysd.A - K*sysd.C, [sysd.B K], sysd.C, [sysd.D 0]);
sysd_down.sampleTime = sysd.sampleTime;

% Simulate model up
time_up = t(1:l/2);
[~,~,x] = mc.lsim(sysd_up, [u_up; e_up], time_up);
hold on

% Simulate model down
time_down = t(l/2+1:end);
x0 = x(:, end); % Initial state
mc.lsim(sysd_down, [u_down; e_down], time_down, x0);

% Place legend, title, labels for the signals
subplot(2, 1, 1)
legend('Up model', 'Down model', 'Measured');
title('Hanging load - Hydraulic system')
xlabel('Time [s]')
ylabel('Hanging load position');

% Place legend, title, labels for the noise
subplot(2, 1, 2)
legend('Noise up', 'Noise down');
title('Hanging load - Hydraulic system')
xlabel('Time [s]')
ylabel('Noise');
