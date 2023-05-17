% Output-error
% Input: u(input signal), y(output signal), np(number of poles of A(q)), nz(number of zeros of B(q)), sampleTime, delay(optional), forgetting(optional)
% Output: sysd(Discrete state space model with noise), K(Kalman gain matrix)
% Example 1: [sysd, K] = mi.oe(u, y, np, nz, sampleTime);
% Example 2: [sysd, K] = mi.oe(u, y, np, nz, sampleTime, delay);
% Example 3: [sysd, K] = mi.oe(u, y, np, nz, sampleTime, delay, forgetting);
% A(q)*y(t) = B(q)*u(t) + A(q)*e(t)
% Author: Daniel Mårtensson, Januari 2023

function [sysd, K] = oe(varargin)
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

  % Get the sample time
  if(length(varargin) >= 5)
    sampleTime = varargin{5};
    if(sampleTime <= 0)
      error('sampleTime <= 0');
    end
  else
    error('Missing sample time');
  end

  % Get the delay
  if(length(varargin) >= 6)
    delay = varargin{6};
  else
    delay = 0;
  end

  % Get the lambda factor
  if(length(varargin) >= 7)
    forgetting = varargin{7};
    if(forgetting <= 0)
      error('forgetting <= 0');
    end
  else
    forgetting = 1; % If no lambda forgetting factor was given
  end

  % Identify
  [sysd, K] = mi.rls(u, y, np, nz, np, sampleTime, delay, forgetting);
end
