% Clear all
clear all

% Create disturbance signal
t = linspace(0, 100, 1000);
e = randn(1, length(t));

% Create disturbance model
H = tf([1], [1 3]);

% Simulate
y = lsim(H, e, t);
close

% Identify a model
k = 100;
sampleTime = t(2) - t(1);
ktune = 0.01;
delay = 0;
systemorder = 2;
[H, K] = sra(y, k, sampleTime, ktune, delay, systemorder);

% Observer
H.A = H.A - K*H.C;

% Create new signals
[y, t] = gensig('square', 10, 10, 100);
y = [y*5 y*2 -y 10*y -2*y];
t = linspace(0, 100, length(y));

% Add some noise
y = y + 2*randn(1, length(y));

% Simulate
lsim(H, y, t);
