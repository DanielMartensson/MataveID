% Kalman Filter
% Input: sys(Model), u(Input), y(Output), Q(Covariance disturbance covariance), R(Measurement noise covariance)
% Output: xhat(Estimated state vector)
% Example 1: [xhat] = mi.kf(sys, u, y, Q, R);
% Author: Daniel Mårtensson, December 2024

function [xhat] = kf(varargin)
  % Check if there is some input arguments
  if(isempty (varargin))
    error ('Missing input')
  end

  % Get model
  if(length(varargin) >= 1)
    sys = varargin{1};
  else
    error('Missing inputs')
  end

  % Get input
  if(length(varargin) >= 2)
    u = varargin{2};
  else
    error('Missing u')
  end

  % Get output
  if(length(varargin) >= 3)
    y = varargin{3};
  else
    error('Missing y')
  end

  % Get Q
  if(length(varargin) >= 4)
    Q = varargin{4};
  else
    error('Missing Q')
  end

  % Get R
  if(length(varargin) >= 5)
    R = varargin{5};
  else
    error('Missing R')
  end

  % Check if the model is a transfer function
  if(strcmp(sys.type,'TF'))
    sys = mc.tf2ss(sys);
  end

  % Get matrices
  A = sys.A;
  B = sys.B;
  C = sys.C;

  % Get state size
  L = size(A, 1);

  % Initial covaraiance
  P = eye(L);

  % Initial state
  x = zeros(L, 1);

  % Get the length
  N = length(y);

  % Create states
  xhat = zeros(L, N);

  % Run the iteration of the kalman filter
  for k = 1:N
    % Prediction
    dx = A * x + B * u(:, k);

    % Compute covaraiance
    P = A * P * A' + Q;

    % Innovation covaraiance
    S = C * P * C' + R;

    % Find kalman gain
    K = linsolve(S, P * C');

    % Update state
    x = dx + K * (y(:, k) - C * dx);

    % Update covaraiance
    P = (eye(L) - K * C) * P;

    % Save states
    xhat(:, k) = x;
  end

end
