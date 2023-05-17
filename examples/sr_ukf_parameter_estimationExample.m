clc; clear; close all;


% Initial parameters
L = 3;                  % How many states we have
e = 0.1;                % Tuning factor for noise
alpha = 0.1;            % Alpha value - A small number like 0.01 -> 1.0
beta = 2.0;             % Beta value - Normally 2 for gaussian noise
Re = e*eye(L);          % Initial noise covariance matrix - Recommended to use identity matrix
Sw = eye(L);            % Initial covariance matrix - Recommended to use identity matrix
what = zeros(L, 1);     % Estimated parameter vector
d = zeros(L, 1);        % This is our measurement
x = [4.4; 6.2; 1.0];    % State vector
lambda_rls = 1.0;       % RLS forgetting parameter between 0.0 and 1.0, but very close to 1.0

% Our transition function - This is the orifice equation Q = a*sqrt(P2 - P1) for hydraulics
G = @(x, w) [w(1)*sqrt(x(2) - x(1));
            % We only need to use w(1) so we assume that w(2) and w(3) will become close to 1.0 
             w(2)*x(2);
             w(3)*x(3)];
             
% Start clock time
tic

% Declare arrays 
samples = 100;
WHAT = zeros(samples, L);
E = zeros(samples, L);

% Do SR-UKF for parameter estimation
for i = 1:samples
  % Assume that this is our measurement 
  d(1) = 5 + e*randn(1,1);
  
  % This is just to make sure w(2) and w(3) becomes close to 1.0
  d(2) = x(2);
  d(3) = x(3);
  
  % SR-UKF
  [Sw, what] = Mid.sr_ukf_parameter_estimation(d, what, Re, x, G, lambda_rls, Sw, alpha, beta, L);
  
  % Save the estimated parameter 
  WHAT(i, :) = what';
  
  % Measure the error
  E(i, :) = abs(d - G(x, what))';
end

% Stop the clock
toc 

% Print the data
[M, N] = size(WHAT);

for k = 1:N                                 
  subplot(3,1,k);
  plot(1:M, WHAT(:,k), '-', 1:M, E(:, k), '--');
  title(sprintf('Parameter estimation for parameter w%i', k));
  ylabel(sprintf('w%i', k));
  grid on
  legend('Estimated parameters', 'Parameter error')
end
