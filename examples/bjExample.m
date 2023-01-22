% Clear all
clear all
close all

% Create system model
G = tf(1, [1 1.5 2]);

% Create disturbance model
H = tf([2 3], [1 5 6]);

% Create input signal
[u, t] = gensig('square', 10, 10, 100);
u = [u*5 u*2 -u 10*u -2*u];
t = linspace(0, 30, length(u));

% Create disturbance signal
e = randn(1, length(t));

% Simulate with noise
d = lsim(H, e, t);
y = lsim(G, u, t) + d
close

% Use Box-Jenkins to find the system model and the disturbance model
k = 50;
sampleTime = t(2) - t(1);
ktune = 0.5;
delay = 0;
systemorder_sysd = 2;
systemorder_sysh = 2;
[sysd, K1, sysh, K2] = bj(u, y, k, sampleTime, ktune, delay, systemorder_sysd, systemorder_sysh);

% Plot sysd
[sysd_y, sysd_t] = lsim(sysd, u, t);
close all
plot(t, y, sysd_t, sysd_y);
legend('Measurement', 'Identified')
grid on
title('System model', 'FontSize', 20)

% Plot sysh
figure(2)
[sysh_y, sysh_t] = lsim(sysh, e, t);
close(2)
figure(2)
plot(t, d, sysh_t, sysh_y);
legend('Measurement', 'Identified')
grid on
title('Disturbance model', 'FontSize', 20)

