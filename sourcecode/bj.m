% Box-Jenkins
% Input: u(input signal), y(output signal), k(Hankel row length), sampleTime, ktune(kalman tuning, optimal), delay(optional), systemorder_sysd(optional), systemorder_sysh(optional)
% Output: sysd(Discrete state space model), K1(Kalman Gain matrix for discreate state space model), sysh(Disturbance model), K2(Kalman Gain matrix for disturbance state space model)
% Example 1: [sysd, K1, sysh, K2] = bj(u, y, k, sampleTime);
% Example 2: [sysd, K1, sysh, K2] = bj(u, y, k, sampleTime, ktune);
% Example 3: [sysd, K1, sysh, K2] = bj(u, y, k, sampleTime, ktune, delay);
% Example 4: [sysd, K1, sysh, K2] = bj(u, y, k, sampleTime, ktune, delay, systemorder_sysd);
% Example 5: [sysd, K1, sysh, K2] = bj(u, y, k, sampleTime, ktune, delay, systemorder_sysd, systemorder_sysh);

function [sysd, K1, sysh, K2] = bj(varargin)
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
    error('Missing output')
  end

  % Get k - block rows
  if(length(varargin) >= 3)
    k = varargin{3};
  else
    error('Missing amout of block rows')
  end

  % Get the sample time
  if(length(varargin) >= 4)
    sampleTime = varargin{4};
  else
    error('Missing sample time');
  end

  % Get the kalman filter tuning
  if(length(varargin) >= 5)
    ktune = varargin{5};
  else
    ktune = 1;
  end

  % Get the delay
  if(length(varargin) >= 6)
    delay = varargin{6};
  else
    delay = 0; % If no delay was given
  end

  % Get the order of the system
  if(length(varargin) >= 7)
    systemorder_sysd = varargin{7};
    if (systemorder_sysd <= 0)
      systemorder_sysd = -1;
    end
  else
    systemorder_sysd = -1; % If no order was given
  end

  % Get the order of the system
  if(length(varargin) >= 8)
    systemorder_sysh = varargin{8};
    if (systemorder_sysh <= 0)
      systemorder_sysh = -1;
    end
  else
    systemorder_sysh = -1; % If no order was given
  end

  % Check if u and y has the same length
  if(length(u) ~= length(y))
    error('Input(u) and output(y) has not the same length')
  end

  % Get system model
  [sysd, K1] = cca(u, y, k, sampleTime, delay, systemorder_sysd);

  % Find the disturbance d = H*e
  Ad = sysd.A;
  Bd = sysd.B;
  Cd = sysd.C;
  Dd = sysd.D;
  x = zeros(systemorder_sysd, 1);
  for i = 1:size(u, 2)
    yhat(:,i) = Cd*x + Dd*u(:,i);
    x = Ad*x + Bd*u(:,i); % Update state vector
  end
  d = y - yhat;

  % Get the disturbance model
  [sysh, K2] = sra(d, k, sampleTime, ktune, delay, systemorder_sysh);

end
