clc; clear close all;
N = 200;
t = linspace(0, 100, N); % Time vector
u = sin(t); % Input signal
G = tf(1, [1 0.2 3]); % Model
y = lsim(G, u, t); % Simulation
close
k = 20;
sampleTime = t(2) - t(1);
systemorder = 2;
delay = 0;
sysd = moesp(u, y, k, sampleTime, delay, systemorder); % This won't result well with N4SID
close
lsim(sysd, u, t);
hold on
plot(t, y)