% Observer Kalman Filter Identification
% Input: inputs, states(outputs), derivatives, t(time vector), sample time
% Output: sysd(Discrete state space model), K(Kalman gain matrix)
% Example: [sysd, K] = okid(inputs, states, derivatives, t, sampleTime);
% Author: Daniel Mårtensson, Juli 2020

function [sysd, K] = okid(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
  end
  
  % Get inputs
  if(length(varargin) >= 1)
    inputs = varargin{1};
  else
    error('Missing inputs')
  end
  
  % Get states
  if(length(varargin) >= 2)
    states = varargin{2};
  else
    error('Missing states')
  end
  
  % Get derivatives
  if(length(varargin) >= 3)
    derivatives = varargin{3};
  else
    error('Missing derivatives')
  end
  
  % Get time
  if(length(varargin) >= 4)
    t = varargin{4};
  else
    error('Missing time')
  end
  
  % Get sample time
  if(length(varargin) >= 5)
    sampleTime = varargin{5};
  else
    error('Missing sample time')
  end
  
  % Do error checking between states and inputs
  if(size(states, 2) ~= size(inputs, 2))
    error('States and inputs need to have the same length of columns - Try transpose')
  end
  
  % Do error checking between derivatives and inputs
  if(size(derivatives, 1) ~= size(inputs, 2))
    error('Derivatives and inputs need to have the same length - Try transpose')
  end
  
  % Flip them so they are standing "up"
  Y = states';
  U = inputs';
  
  % Find the linear solution Ax = b
  X = linsolve([Y U], derivatives)'; % Important with transpose
  
  % Create the state space model
  m = size(Y, 2);
  A = X(:, 1:m);
  n = size(U, 2);
  B = X(:, m+1:m+n);
  sys = ss(0, A, B); % 0 = delay
  sysd = c2d(sys, sampleTime);
  
  % Find the kalman gain matrix K
  y = lsim(sysd, inputs, t);
  y = y(:, 1:2:end); % Remove the discrete shape
  close
  noise = states - y;
  Q = sysd.C'*sysd.C; % This is a standard way to select Q matrix for a kalman filter C'*C
  R = cov(noise'); % Important with transpose
  [K] = lqe(sysd, Q, R);
end
