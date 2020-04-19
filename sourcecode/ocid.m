% Observer Controller Identification
% Input: r(reference signal), uf(feedback signal), y(output signal), sampleTime, delay(optional), regularization(optional), systemorder(optional)
% Output: sysd(Discrete state space model), K(Kalman gain matrix)
% Example 1: [sysd, K, L] = ocid(r, uf, y, sampleTime, delay, regularization, systemorder);
% Example 2: [sysd, K, L] = ocid(r, uf, y, sampleTime);
% Author: Daniel Mårtensson, 19 April 2020. Follows NASA document ID 19920072673

function [sysd, K, L] = ocid(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
  end
  
  % Get reference
  if(length(varargin) >= 1)
    r = varargin{1};
  else
    error('Missing reference')
  end
  
  % Get feedback
  if(length(varargin) >= 2)
    uf = varargin{2};
  else
    error('Missing feedback')
  end
  
  % Get output
  if(length(varargin) >= 3)
    y = varargin{3};
  else
    error('Missing output')
  end
  
  % Get the sample time
  if(length(varargin) >= 4)
    sampleTime = varargin{4};
  else
    error('Missing sample time');
  end
  
  % Get the delay
  if(length(varargin) >= 5)
    delay = varargin{5};
  else
    delay = 0; % If no delay was given
  end
  
  % Get the regularization parameter
  if(length(varargin) >= 6)
    regularization = varargin{6};
    if (regularization <= 0)
      regularization = 0;
    end
  else
    regularization = 0; % If no regularization was given
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
  if(length(uf) ~= length(y))
    error('Feedback(uf) and output(y) has not the same length')
  end
  
  % Get the dimensions first
  q = size(y, 1); % Dimension of output
  l = size(y, 2); % Total length
  m = size(uf, 1); % Dimension of input
  p = l/2-1; % We select half minus -1 else Ybar can be unstable for SISO noise free case
  
  % Create V matrix
  V = zeros((q+m)*p + m, l-p);
  
  % Begin with the first m rows for V
  for k = 1:m
    V(k, 1:l-p) = -uf(k, p+1:l) + r(k, p+1:l); 
  end
  
  % Now do the rest (q+m)*l rows for V. We want to implement v = [u;y] into V - This is equation 8
  positionrow = 1;
  for row = m:(q+m):(q+m)*p
    % For u
    for k = 1:m
      V(row + k, 1:l-p) = -uf(k, p-positionrow+1:l-positionrow) + r(k, p-positionrow+1:l-positionrow);
    end
    % For y
    for k = 1:q
      V(row + k + m, 1:l-p) = y(k, p-positionrow+1:l-positionrow);
    end
    positionrow = positionrow + 1;
  end
  
  % Important to have part of y
  y_part = zeros(q, 1:l-p);
  u_part = zeros(q, 1:l-p);
  for k = 1:q
    y_part(k, 1:l-p) = y(k, p+1:l);
    u_part(k, 1:l-p) = uf(k, p+1:l);
  end
  yt = [y_part; u_part];
  
  % Solve for non-filtred markov parameters with tikhonov regularization
  Ybar = yt*inv(V'*V + regularization*eye(size(V'*V)))*V';
  
  % Find D matrix. It's the first row of Ybar
  D = zeros(q, m);
  for k = 1:q
    D(k, 1:m) = Ybar(k, 1:m); % This is YBar11(0)
  end
  
  % Remove D from Ybar
  YbarNoD = zeros(q+m, (q+m)*p);
  for i = 1:q+m
    YbarNoD(i, 1:(q+m)*p) = Ybar(i, m+1:(q+m)*p+m);
  end
  
  
  % We need to split YbarNoD into Ybar11, Ybar12, Ybar21 and Ybar22
  Ybar11 = YbarNoD(1:q, 1:p); 
  Ybar12 = YbarNoD(1:q, p+1:p+p);
  Ybar21 = YbarNoD(q+1:q+m, 1:p);
  Ybar22 = YbarNoD(q+1:q+m, p+1:p+p);
  
  % Find the markovs now
  Y11 = findMarkovs(Ybar11, Ybar12, q, p, 0); % CAB - System markov parameters
  Y12 = findMarkovs(Ybar12, Ybar12, q, p, 1); % CAG - System observer markov parameters
  Y21 = findMarkovs(Ybar21, Ybar22, m, p, 0); % FAB - Controller markov parameters
  Y22 = findMarkovs(Ybar22, Ybar22, m, p, 1); % FAG - Controller observer markov parameters
  
  % Combine them - This is what the report is asking for
  Y = [Y11 Y12; 
       Y21 Y22];
       
  % Time to find A, B, C, D, K, L from measurement data by using ERA/DC     
  sysd = eradc([[D;D*0] Y], m, sampleTime, delay, systemorder);
  % This need to work on! Should we estimate for every CAB, CAG, FAB, FAG like OKID?
  
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

% Find the markov parameters
function [Y] = findMarkovs(Ybar1, Ybar2, q, p, a)
  Y = zeros(q, p);
  for k = 0:p-1
    Yk = getY_k(Ybar1, q, k);
    
    % Find the sum
    Ysum = zeros(q, q);
    for i = 0:k-a
      Ybari = getY_k(Ybar2, q, k-i);
      Yi = getY_k(Y, q, k-i);
      Ysum = Ysum + Ybari*Yi;
    end
    
    % Save the markov parameters
    Y(:, 1 + k*q:k*q + q) = Yk - Ysum;
  end
end
