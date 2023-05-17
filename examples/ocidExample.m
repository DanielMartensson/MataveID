clc; close all; clear;

%% Matrix A
A = [0 1  0  0;
    -7 -5 0  1;
     0 0  0  1;
     0 1 -8 -5];

%% Matrix B
B = [0 0;
     1 0;
     0 0;
     0 1];

%% Matrix C
C = [1 0 0 0;
     0 0 0 1];

%% Model and signals
delay = 0;
sys = mc.ss(delay, A, B, C);
t = linspace(0, 20, 1000);
r = [linspace(5, -11, 100) linspace(7, 3, 100) linspace(-6, 9, 100) linspace(-7, 1, 100) linspace(2, 0, 100) linspace(6, -9, 100) linspace(4, 1, 100) linspace(0, 0, 100) linspace(10, 17, 100) linspace(-30, 0, 100)];
r = [r;2*r]; % MIMO

%% Feedback
Q = sys.C'*sys.C;
R = [1 0; 0 1];
L = mc.lqr(sys, Q, R);
[feedbacksys] = mc.reg(sys, L);
yf = mc.lsim(feedbacksys, r, t);
close

%% Add noise
v = 2*randn(1, 1000);
for i = 1:length(yf)
  noiseSigma = 0.10*yf(:, i);
  noise = noiseSigma*v(i); % v = noise, 1000 samples -1 to 1
  yf(:, i) = yf(:, i) + noise;
end

%% Identification
uf = yf(3:4, :); % Input feedback signals
y = yf(1:2, :); % Output feedback signals
regularization = 10000;
modelorder = 6;
sampleTime = t(2) - t(1);
alpha = 20; % Filtering integer parameter
[sysd, K, L] = ocid(r, uf, y, sampleTime, alpha, regularization, modelorder);

%% Validation
u = -uf + r; % Input signal %u = -Lx + r = -uf + r
yt = mc.lsim(sysd, u, t);
close

%% Check
plot(t, yt(1:2, 1:2:end), t, yf(1:2, :))
legend("Identified 1", "Identified 2", "Data 1", "Data 2", 'location', 'northwest')
grid on