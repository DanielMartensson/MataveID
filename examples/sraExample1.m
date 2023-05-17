% Clear all
clear all

% Create system model
G = mc.tf(1, [1 1.5 2]);

% Create disturbance model
H = mc.tf([2 3], [1 5 6]);

% Create input signal
[u, t] = mc.gensig('square', 10, 10, 100);
u = [u*5 u*2 -u 10*u -2*u];
t = linspace(0, 30, length(u));

% Create disturbance signal
e = randn(1, length(t));

% Simulate with noise-
y = mc.lsim(G, u, t) + mc.lsim(H, e, t);
close

% Identify a system model
k = 50;
sampleTime = t(2) - t(1);
delay = 0;
systemorder = 2;
Ghat = mi.cca(u, y, k, sampleTime, delay, systemorder);

% Find the disturbance d = H*e
Ad = Ghat.A;
Bd = Ghat.B;
Cd = Ghat.C;
Dd = Ghat.D;
x = zeros(systemorder, 1);
for i = 1:size(t, 2)
  yhat(:,i) = Cd*x + Dd*u(:,i);
  x = Ad*x + Bd*u(:,i); % Update state vector
end
d = y - yhat;

% Identify the disturbance model
systemorder = 2;
ktune = 0.5;
[Hhat] = mi.sra(d, k, sampleTime, ktune, delay, systemorder);

% Simulate the disturbance model
[dy, dt] = mc.lsim(Hhat, e, t);
close
plot(dt, dy, t, d);
legend('d = Hhat*e(t)', 'd = y - yhat')
grid on

