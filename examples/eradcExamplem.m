clc; clear; close all

%% Parameters
m1 = 2.3;
m2 = 3.1;
k1 = 8.5;
k2 = 5.1;
b1 = 3.3;
b2 = 5.1;

A=[0                 1   0                                              0
  -(b1*b2)/(m1*m2)   0   ((b1/m1)*((b1/m1)+(b1/m2)+(b2/m2)))-(k1/m1)   -(b1/m1)
   b2/m2             0  -((b1/m1)+(b1/m2)+(b2/m2))                      1
   k2/m2             0  -((k1/m1)+(k1/m2)+(k2/m2))                      0];
B=[0 0;
   1/m1 0;
   0 0 ;
   (1/m1)+(1/m2) 1/m2];
C=[0 0 1 0;
   0 1 0 0];
D=[0 0;
   0 0];
delay = 0;

%% Model
buss = ss(delay,A,B,C,D);

%% Simulation
[g, t] = impulse(buss, 10);

%% Add 15% noise
v = 2*randn(1, 1000);
for i = 1:length(g)-1
  noiseSigma = 0.15*g(i);
  noise = noiseSigma*v(i); % v = noise, 1000 samples -1 to 1
  g(i) = g(i) + noise;
end

%% Identification
systemorder = 10;
[sysd] = eradc(g, t(2) - t(1), systemorder);

%% Validation
gt = impulse(sysd, 10);
close

%% Check
plot(t, g, t, gt(:, 1:2:end))
legend('Data 1', 'Data 2', 'Identified 1', 'Identified 2', 'location', 'northwest')
grid on