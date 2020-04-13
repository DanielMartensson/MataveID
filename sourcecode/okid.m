% Observer Kalman Filter Identification
% Input: u(input signal), y(output signal), sampleTime, delay(optional), regularization(optional), systemorder(optional)
% Output: sysd(Discrete state space model), K(Kalman gain matrix)
% Example 1: [sysd, K] = okid(u, y, sampleTime, delay, regularization, systemorder);
% Example 2: [sysd, K] = okid(u, y, sampleTime);
% Author: Daniel Mårtensson, December 2017
% Update January 2019 - Better hankel matrix that fix the 1 step delay.
% Update 14 April 2020 - For MIMO data and follows NASA document ID 19910016123

function [sysd, K] = okid5(varargin)
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
  
  % Get the delay
  if(length(varargin) >= 4)
    delay = varargin{4};
  else
    delay = 0; % If no delay was given
  end
  
  % Get the regularization parameter
  if(length(varargin) >= 5)
    regularization = varargin{5};
    if (regularization <= 0)
      regularization = 0;
    end
  else
    regularization = 0; % If no regularization was given
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
  
  % Get the dimensions first
  q = size(y, 1); % Dimension of output
  l = size(y, 2); % Total length
  m = size(u, 1); % Dimension of input
  p = l/2-1; % We select half minus -1 else Ybar can be unstable for SISO noise free case
  
  % Create V matrix
  V = zeros((q+m)*p + m, l-p);
  
  % Begin with the first m rows for V
  for k = 1:m
    V(k, 1:l-p) = u(k, p+1:l);
  end
  
  % Now do the rest (q+m)*l rows for V. We want to implement v = [u;y] into V - This is equation 8
  positionrow = 1;
  for row = m:(q+m):(q+m)*p
    % For u
    for k = 1:m
      V(row + k, 1:l-p) = u(k, p-positionrow+1:l-positionrow);
    end
    % For y
    for k = 1:q
      V(row + k + m, 1:l-p) = y(k, p-positionrow+1:l-positionrow);
    end
    positionrow = positionrow + 1;
  end
  
  % Important to have part of y
  y_part = zeros(q, 1:l-p);
  for k = 1:q
    y_part(k, 1:l-p) = y(k, p+1:l);
  end
  
  % Solve for non-filtred markov parameters with tikhonov regularization
  Ybar = y_part*inv(V'*V + regularization*eye(size(V'*V)))*V';
  
  % Get D matrix
  D = zeros(q, m);
  for k = 1:q
    D(k, 1:m) = Ybar(k, 1:m); % This is YBar_{-1}
  end

  % Remove D from Ybar
  YbarNoD = zeros(q, (q+m)*p);
  for i = 1:q
    YbarNoD(i, 1:(q+m)*p) = Ybar(i, m+1:(q+m)*p+m);
  end
  
  % Time to find the impulse response: 
  % Yk = Ybar1_k + sum_i_to_k-1(Y_k-i-1*Ybar2_i) + Ybar2_k*D
  % Yo_k = -Ybar2_k + sum_i_to_k-1(Y_k-i-1*Ybar2_i); 
  Y = zeros(m, p*m);
  Yo = zeros(m, p*m);
  for k = 0:p-1
    [Ybar1_k, Ybar2_k] = getYbar1_2(YbarNoD, q, m, k);
    
    % Find the sum
    Ysum = zeros(m, m);
    Yosum = zeros(m, m);
    for i = 0:k-1
      [Ybar1_i, Ybar2_i] = getYbar1_2(YbarNoD, q, m, i);
      [Yi] = getY_k(Y, m, k-i-1);
      [Yoi] = getY_k(Yo, m, k-i-1);
      Ysum = Ysum + Ybar2_i*Yi;
      Yosum = Yosum + Ybar2_i*Yoi;
    end
    
    % Save the markov parameters
    Y(:, 1 + k*m:k*m + m) = Ybar1_k + Ysum + Ybar2_k*D; % This are the CA^kB system markov parameters
    Yo(:, 1 + k*m:k*m + m) = -Ybar2_k + Yosum; % This are the CA^kM observer markov parameters
    
  end
 
  % Time to find A, B, C, D, K from measurement data by using ERA/DC
  sysd = eradc([D Y], m, sampleTime, delay, systemorder)
  O = createO(sysd.A, sysd.C, p);
  K = inv(O'*O)*O'*Yo'; % Our kalman gain matrix
  
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

% This will get [Ybar1, Ybar2]
function [Ybar1, Ybar2] = getYbar1_2(YbarNoD, q, m, k)
    Ybar1 = zeros(q, m); % C(A+MC)^k(B+MD)
    Ybar2 = zeros(q, q); % -C(A+MC)^kM
    Ybar1Ybar2 = zeros(q, m+q);
    
    % Do Ybar1Ybar2
    for i = 1:q
      Ybar1Ybar2(i, 1:m+q) = YbarNoD(i, 1+(q+m)*k: (q+m)*k + q+m);
    end
    
    % Split Ybar1Ybar2 to Ybar1 and Ybar2
    for i = 1:q
      Ybar1(i, 1:m) = Ybar1Ybar2(i, 1:m);
      Ybar2(i, 1:q) = Ybar1Ybar2(i, m+1:q+q);
    end

end

% Create the special Observabillity matrix
function PHI = createO(A, C, N)
  PHI = [];
  for i = 1:N
    PHI = vertcat(PHI, C*A^i);
  end
end
