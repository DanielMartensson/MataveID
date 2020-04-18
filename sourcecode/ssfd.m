% State Space Frequency Domain
% Input: u(input signal), y(output signal), sampleTime, systemorderTF, delay(optional), systemorder(optional)
% Output: sysd(Discrete state space model)
% Example 1: [sysd] = ssfd(u, y, sampleTime, modelorderTF, delay, systemorder);
% Example 2: [sysd] = ssfd(u, y, sampleTime, systemorderTF);
% Author: Daniel Mårtensson, April 2020. Follows NASA documentat ID 19920023413 

function [sysd] = ssfd2(varargin)
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
  
  % Get the order if the system
  if(length(varargin) >= 6)
    systemorder = varargin{6};
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
  N = 4*p;
  
  % Get all the numerators and denominators from RLS in for of diagonal matrices
  A = zeros(r, p*r);
  B = zeros(r, p*r);
  for i = 1:r
    Gd = rls(u(i, 1:m), y(i, 1:m), p, p, p, sampleTime, delay, forgetting); % RLS is a perfect choice in this noisy case
    A(i, i:r:p*r) = Gd.den(2:p+1); % Ignore the first 1*z^2
    B(i, i:r:p*r) = Gd.num;
  end
  
  % Find the markov parameters of polynomals A and B
  % This is the standard way to find a impulse response of a TF. Used since Ho-Kalman 1966
  H = zeros(r, r*N);
  for k = 0:N-1
    if(k == 0)
      Bk = getY_k(B, r, k);
      H(:, 1 + k*r:k*r + r) = Bk; % B0
    elseif(and(k > 0, k < p))
      Bk = getY_k(B, r, k); 
      AH = zeros(r, r);
      for j = 0:k-1
        Ak = getY_k(A, r, j);
        Hk = getY_k(H, r, k-j);
        AH = AH + Ak*Hk;
      end
      H(:, 1 + k*r:k*r + r) = Bk - AH;
    elseif(k >= p)
      AH = zeros(r, r);
      for j = 0:p-1
        Ak = getY_k(A, r, j);
        Hk = getY_k(H, r, k-j);
        AH = AH + Ak*Hk;
      end
      H(:, 1 + k*r:k*r + r) = -AH;
    end
  end
  
  % Get our state space model by using ERA/DC algorithm
  sysd = eradc(H, r, sampleTime, delay, systemorder);
  
end

% Get the Y_k from Y
function [Yk] = getY_k(Y, m, k)
  Yk = zeros(m, m);
  if(k >= 0)
    for i = 1:m
      Yk(i, 1:m) = Y(i, 1 + k*m:k*m + m);
    end
  end
end
