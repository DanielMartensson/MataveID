clc; clear; close all;

%% Frequency input
t = linspace(0.0, 100, 30000);
u1 = 2*sin(2*pi*5.*t); % 5 Hz
u2 = 6*sin(2*pi*10.*t); % 10 Hz
u3 = 10*sin(2*pi*20.*t); % 20 Hz
u4 = 20*sin(2*pi*8.*t); % 8 Hz
u = u1 + u2 + u3 + u4;

%% Noise
u = u + 5*randn(1, 30000);

%% Identify what frequencies and amplitudes we had!
mi.spa(u, t);