% Filtfilt2 - A filter with no or less phase shifting. Very simple to use.
% Input: y(noisy signal), t(time signal), K(optional filter factor)
% Output: y(clean signal)
% Example 1: [y] = filtfilt2(y, t)
% Example 2: [y] = filtfilt2(y, t, K)
% Author: Daniel Mårtensson, April 2020

function [y] = filtfilt2(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
  end
  
  % Get input
  if(length(varargin) >= 1)
    y = varargin{1};
  else
    error('Missing input y')
  end
  
  % Get time
  if(length(varargin) >= 2)
    t = varargin{2};
  else
    error('Missing input t')
  end
  
  % Get filter factor
  if(length(varargin) >= 3)
    K = varargin{3};
  else
    K = 0.1;
  end
  
  % Create transfer function model of a low pass filter
  G = tf(1, [K 1]);
  
  % Simulate the noisy signal
  y1 = lsim(G, y, t);
  close % It will show a popup for lsim - Close it
  
  % Flip
  y2 = flip(y1);
  
  % Run the simulation again
  y3 = lsim(G, y2, t);
  close
  
  % Flip - Done
  y = flip(y3);
  
end
