% Kalman Filter
% Input: sys(Model), u(Input), y(Output), Q(Covariance disturbance covariance), R(Measurement noise covariance), x(Initial estimated state), P(Initial covariance)
% Output: xhat(Estimated state vectors), x(Last estimated state), P(Last covariance)
% Example 1: [xhat, x, P] = mi.kf(sys, u, y, Q, R);
% Example 2: [xhat, x, P] = mi.kf(sys, u, y, Q, R, x);
% Example 3: [xhat, x, P] = mi.kf(sys, u, y, Q, R, x, P);
% Author: Daniel Mårtensson, December 2024
% Update: 2025-01-05: Add initial state x and initial covariance P

function [xhat, x, P] = kf(varargin)
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

  % Initial state
  if(length(varargin) >= 6)
    x = varargin{6};
  else
    x = zeros(L, 1);
  end

  % Initial covaraiance
  if(length(varargin) >= 7)
    P = varargin{7};
  else
    P = eye(L);
  end

  % Get the length
  N = length(y);

  % Get initial xhat
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
    K = (P * C') * inv(S);

    % Update state
    x = dx + K * (y(:, k) - C * dx);

    % Update covaraiance
    P = (eye(L) - K * C) * P;

    % Save states
    xhat(:, k) = x;
  end

end
