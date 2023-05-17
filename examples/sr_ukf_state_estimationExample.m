clc; clear; close all;


% Initial parameters
L = 3;                  % How many states we have
r = 1.5;                % Tuning factor for noise
q = 0.2;                % Tuning factor for disturbance
alpha = 0.1;            % Alpha value - A small number like 0.01 -> 1.0
beta = 2.0;             % Beta value - Normally 2 for gaussian noise
Rv = q*eye(L);          % Initial disturbance covariance matrix - Recommended to use identity matrix
Rn = r*eye(L);          % Initial noise covariance matrix - Recommended to use identity matrix
S = eye(L);             % Initial covariance matrix - Recommended to use identity matrix
xhat = [0; 0; 0];       % Estimated state vector
y = [0; 0; 0];          % This is our measurement
u = [0; 0; 0];          % u is not used in this example due to the transition function not using an input signal
x = [0; 0; 0];          % State vector for the system (unknown in reality)

% Our transition function
F = @(x, u) [x(2);
             x(3);
             0.05*x(1)*(x(2) - x(3))];
             
% Start clock time
tic

% Declare arrays 
samples = 200;
X = zeros(samples, L);
XHAT = zeros(samples, L);
Y = zeros(samples, L);
phase = [90;180;140];
amplitude = [1.5;2.5;3.5];

% Do SR-UKF for state estimation
for i = 1:samples
  % Create measurement 
  y = x + r*randn(L, 1);
  
  % Save measurement 
  Y(i, :) = y';
 
  % Save actual state
  X(i, :) = x';
  
  % SR-UKF
  [S, xhat] = mi.sr_ukf_state_estimation(y, xhat, Rn, Rv, u, F, S, alpha, beta, L);

  % Save the estimated parameter 
  XHAT(i, :) = xhat';
  
  % Update process
  x = F(x, u) + q*amplitude.*sin(i-1 + phase);
end

% Stop the clock
toc 

% Print the data
[M, N] = size(XHAT);

for k = 1:N                                 
  subplot(3,1,k);
  plot(1:M, Y(:,k), '-g', 1:M, XHAT(:, k), '-r', 1:M, X(:, k), '-b');
  title(sprintf('State estimation for state x%i', k));
  ylabel(sprintf('x%i', k));
  grid on
  legend('y', 'xhat', 'x')
end
