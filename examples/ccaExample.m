clc; clear; close all;

% Create input signal
amplitude1 = 10;
amplitude2 = 50;
[u1, t] = gensig('square', amplitude1, 100, 200);
[u2, t] = gensig('square', amplitude2, 50, 150);
u = [u1 u2];

% Create time vector
t = linspace(0, 30, length(u));

% Create output signals
G = tf([1], [1 0.9 1]);
y = lsim(G, u, t);
close

% Add much process npise with zero mean
e = 1.5*randn(1, length(y));
yn = y + e;

% Indentify model that have a kalman gain matrix included
sampleTime = t(2) - t(1);
systemorder = 2;
delay = 0;
k = 100; % 100 is tuning parameter
[sysd] = cca(u, yn, k, sampleTime, delay, systemorder);
close


% Simulate the model
[s, ts] = lsim(sysd, [u; e*0], t); % e*0 means that we disable the noise
close
plot(t, yn);
hold all;
plot(ts, s, '--r','linewidth', 2 )
title('CCA');
legend('Real measurement', 'Identified')
grid on