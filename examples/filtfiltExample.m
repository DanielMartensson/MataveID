clc; clear; close all;

%% Model of a mass spring damper system
M = 1; % Kg
K = 500; % Nm/m
b = 3; % Nm/s^2
G = mc.tf([1], [M b K]);

%% Input signal
t = linspace(0.0, 100, 3000);
u = 10*sin(t);

%% Simulation
y = mc.lsim(G, u, t);
close

%% Add 10% noise
v = 2*randn(1, length(y));
for i = 1:length(y)
  noiseSigma = 0.10*y(i);
  noise = noiseSigma*v(i); 
  y(i) = y(i) + noise;
end

%% Filter away the noise
lowpass = 0.2;
[yf] = filtfilt(y, t, lowpass);

%% Check
plot(t, yf, t, y);
legend("Filtered", "Noisy");
