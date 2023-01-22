% Autoregressive Moving Average Exogenous
% Input: u(input signal), y(output signal), np(number of poles of A(q)), nz(number of zeros of B(q)), nze(number of zeros for C(q)), sampleTime, ktune(optional), delay(optional), forgetting(optional)
% Output: sysd(Discrete state space model with noise), K(Kalman gain matrix)
% Example 1: [sysd, K] = armax(u, y, np, nz, nze, sampleTime);
% Example 2: [sysd, K] = armax(u, y, np, nz, nze, sampleTime, ktune);
% Example 3: [sysd, K] = armax(u, y, np, nz, nze, sampleTime, ktune, delay);
% Example 4: [sysd, K] = armax(u, y, np, nz, nze, sampleTime, ktune, delay, forgetting);
% A(q)*y(t) = B(q)*u(t) + C(q)*e(t)
% Author: Daniel Mårtensson, Januari 2023

function [sysd, K] = armax(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get input
  if(length(varargin) >= 1)
    u = varargin{1};
  else
    error('Missing input')
  end

  % Get output
  if(length(varargin) >= 2)
    y = varargin{2};
  else
    error('Missing output');
  end

  % Get number of poles for A(q)
  if(length(varargin) >= 3)
    np = varargin{3};
  else
    error('Missing number of poles A(q)');
  end

  % Get number of zeros for B(q)
  if(length(varargin) >= 4)
    nz = varargin{4};
    if(nz > np)
      error('nz > np');
    end
  else
    error('Missing number of zeros B(q)');
  end

  % Get number of zeros for C(q)
  if(length(varargin) >= 5)
    nze = varargin{5};
    if(nze > np)
      error('nze > np');
    end
  else
    error('Missing number of zeros for C(q)');
  end

  % Get the sample time
  if(length(varargin) >= 6)
    sampleTime = varargin{6};
    if(sampleTime <= 0)
      error('sampleTime <= 0');
    end
  else
    error('Missing sample time');
  end

  % Get the ktune
  if(length(varargin) >= 7)
    ktune = varargin{7};
  else
    ktune = 1;
  end

  % Get the delay
  if(length(varargin) >= 8)
    delay = varargin{8};
  else
    delay = 0;
  end

  % Get the lambda factor
  if(length(varargin) >= 9)
    l = varargin{9};
    if(l <= 0)
      error('forgetting <= 0');
    end
  else
    l = 1; % If no lambda forgetting factor was given
  end

  % Identify
  [sysd, K] = rls(u, y, np, nz, nze, sampleTime, delay, l);

  % If we could not compute the kalman gain matrix
  if(nze ~= np)
    % Find the matrices
    Ad = sysd.A;
    Bd = sysd.B;
    Cd = sysd.C;
    Dd = sysd.D;

    % Create kalman filter
    x = zeros(size(Ad, 1), 1);
    for k = 1:size(u, 2)
      xhat(:,k) = x; % Save the states
      yhat(:,k) = Cd*x + Dd*u(:,k);
      x = Ad*x + Bd*u(:,k); % Update state vector
    end

    % Find the real states
    x = Cd\(y-Dd*u);

    % Find the noise
    e = y - yhat;

    % Find the disturbance
    w = (x - xhat)*ktune;

    % Computing the covariance matrix
    covariance = cov([w' e']); % Old way = [w*w' w*e'; e*w' e*e']/(N-1);

    % Compute Q, R, S for the riccati equation
    nx = size(Ad, 2);
    Q = covariance(1:nx, 1:nx);
    R = covariance(nx+1:nx+l, nx+1:nx+l);
    S = covariance(1:nx, nx+1:nx+l);

    % Create a temporary state space model
    riccati = ss(0, Ad', Cd', Bd', Dd');
    riccati.sampleTime = sampleTime;

    % Find kalman filter gain matrix K
    [~, K] = are(riccati, Q, R, S);
    K = K';
  end
end
