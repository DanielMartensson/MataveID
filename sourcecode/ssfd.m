% State Space Frequency Domain
% Input: u(input signal), y(output signal), sampleTime, systemorderTF, delay(optional), forgetting(optional), systemorder(optional)
% Output: sysd(Discrete state space model)
% Example 1: [sysd] = ssfd(u, y, sampleTime, modelorderTF, delay, forgetting, systemorder);
% Example 2: [sysd] = ssfd(u, y, sampleTime, systemorderTF);
% Author: Daniel Mårtensson, April 2020. Follows almost the same idea behind the NASA documentat ID 19920023413 

function [sysd, Gdi] = ssfd(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
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
    error('Missing output')
  end
  
  % Get the sample time
  if(length(varargin) >= 3)
    sampleTime = varargin{3};
  else
    error('Missing sample time');
  end
  
  % Get the model order for the transfer function
  if(length(varargin) >= 4)
    p = varargin{4};
  else
     error('Missing model order');
  end
  
  % Get the delay
  if(length(varargin) >= 5)
    delay = varargin{5};
  else
    delay = 0; % If no delay was given
  end
  
  % Get the forgetting
  if(length(varargin) >= 6)
    forgetting = varargin{6};
  else
    forgetting = 1; % If no forgetting was given
  end
  
  % Get the order if the system
  if(length(varargin) >= 7)
    systemorder = varargin{7};
    if (systemorder <= 0)
      systemorder = -1;
    end
  else
    systemorder = -1; % If no order was given
  end
  
  % Check if u and y has the same length
  if(length(u) ~= length(y))
    error('Input(u) and output(y) has not the same length')
  end
  
  % Get the amout if signals and the length of markov parameters
  r = size(u, 1);
  m = size(y, 2);
  
  % Get the impulse response of Gdi
  H = [];
  for i = 1:r
    Gdi = rls(u(i, 1:m), y(i, 1:m), p, p, p, sampleTime, delay, forgetting); % RLS is a perfect choice in this noisy case
    g = impulse(Gdi);
    g = g(1:2:length(g)); % Remove the discrete shape - Only necessary for plotting! In this case...no.
    close % A pop up plot will appear from impulse.m
    H = [H;g];
  end
  
  % If we can't divide the length in 2
  if(mod(length(H), 2) > 0)
    H = H(:, 1:end-1);
  end
  
  % Get our state space model by using ERA/DC algorithm
  sysd = eradc(H, r, sampleTime, delay, systemorder);
  
end
