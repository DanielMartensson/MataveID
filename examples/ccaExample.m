clc; clear; close all;

% Create model
G = tf(1, [1 1.5 1]);

% Create control inputs
[u, t] = gensig('square', 10, 10, 100);
u = [u*5 u*2 -u 10*u -2*u];
t = linspace(0, 50, length(u));

% Simulate
y = lsim(G, u, t);
close

% Add noise
yn = y + randn(1, length(y));

% Identify the model
sampleTime = t(2) - t(1);
delay = 0;
systemOrder = 2;
k = 30;
[sysd, K] = cca(u, yn, k, sampleTime, delay, systemOrder);

% Create an observer
delay = sysd.delay;
A = sysd.A;
B = sysd.B;
C = sysd.C;
D = sysd.D;
observer = ss(delay, A - K*C, [B K], C, [D 0]);
observer.sampleTime = sysd.sampleTime;

% Simulate the observer
[yobs, tobs] = lsim(observer, [u; yn], t);
close
plot(t, yn, '-r', tobs, yobs, '-b');
grid on
