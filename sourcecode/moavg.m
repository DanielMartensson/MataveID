% Use moving average to filter the noise
% Returns almost noise free y and the noise e
% Example [t, y, e] = moavg(t, y, window);
% Author: Daniel Mårtensson, November 2017

function [t, y, e] = moavg(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
  end
  
  % Get the time
  if(length(varargin) >= 1)
    t = varargin{1};
  else
    error('Missing time')
  end
  
  % Get the signal
  if(length(varargin) >= 2)
    y = varargin{2};
  else
    error('Missing signal');
  end
  
  % Get the window
  if(length(varargin) >= 3)
    window = varargin{3};
  else
    error('Missing window');
  end
  
  
  dy = filter(ones(window,1)/window, 1, y); %# moving average
  e = y - dy; % Find the noise
  y = dy; % Over write
  
end
