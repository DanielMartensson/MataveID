clc; clear; close all;


%% Model of a mass spring damper system
M = 5; % Kg
K = 100; % Nm/m
b = 52; % Nm/s^2
G = tf([1], [M b K]);

%% Frequency response
t = linspace(0, 50, 3000);
[u, fs] = chirp(t);

%% Simulation
y = lsim(G, u, t);
close all

% Add noise
y = y + 0.0001*randn(1, length(y));

%% Identify bode diagram
idbode(u, y, fs);

%% Check
bode(G);