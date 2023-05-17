clc; clear close all;
[u, t] = mc.gensig('square', 10, 10, 100);
G = mc.tf(1, [1 0.8 3]); % Model
y = mc.lsim(G, u, t); % Simulation
y = y + 0.4*rand(1, length(t));
close
k = 30;
sampleTime = t(2) - t(1);
systemorder = 3;
delay = 0;
ktune = 0.01;
[sysd, K] = moesp(u, y, k, sampleTime, ktune, delay, systemorder); % This example works better with MOESP, rather than N4SID

% Create the observer
observer = mc.ss(sysd.delay, sysd.A - K*sysd.C, [sysd.B K], sysd.C, [sysd.D sysd.D*0]);
observer.sampleTime = sysd.sampleTime;

% Check observer
[yf, tf] = mc.lsim(observer, [u; y], t);
close
plot(tf, yf, t, y)
grid on
