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
buss = mc.ss(delay,A,B,C,D);

%% Simulation
[g, t] = mc.impulse(buss, 10);

% Reconstruct the input impulse signal from impulse.m
u = zeros(size(g));
u(1) = 1;

%% Add 15% noise
v = 2*randn(1, 1000);
for i = 1:length(g)-1
  noiseSigma = 0.15*g(i);
  noise = noiseSigma*v(i); % v = noise, 1000 samples -1 to 1
  g(i) = g(i) + noise;
end

%% Identification
systemorder = 10;
ktune = 0.09;
sampleTime = t(2) - t(1);
delay = 0;
[sysd, K] = eradc(g, sampleTime, ktune, delay, systemorder);

% Create the observer
observer = mc.ss(sysd.delay, sysd.A - K*sysd.C, [sysd.B K], sysd.C, [sysd.D sysd.D*0]);
observer.sampleTime = sysd.sampleTime;

%% Validation
[gf, tf] = mc.lsim(observer, [u; g], t);
close

%% Check
plot(t, g, tf, gf)
legend('Data 1', 'Data 2', 'Identified 1', 'Identified 2', 'location', 'northwest')
grid on
