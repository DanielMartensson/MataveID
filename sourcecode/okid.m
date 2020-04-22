% Observer Kalman Filter Identification
% Input: u(input signal), y(output signal), sampleTime, delay(optional), regularization(optional), systemorder(optional)
% Output: sysd(Discrete state space model), K(Kalman gain matrix)
% Example 1: [sysd, K] = okid(u, y, sampleTime, delay, regularization, systemorder);
% Example 2: [sysd, K] = okid(u, y, sampleTime);
% Author: Daniel Mårtensson, December 2017
% Update January 2019 - Better hankel matrix that fix the 1 step delay.
% Update 22 April 2020 - For MIMO data and follows NASA document ID 19910016123

function [sysd, K] = okid(varargin)
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
  p = l/2-1; % We select half minus -1 else Ybar can be unstable for noise free case
  
  % Save the system markov parameters and observer markov parameters here
  CAB = zeros(q, p);
  CAM = zeros(q, p);
  
  % This method computes markov parameters for every signal each. The reason where it's 1 everywhere is because we
  % Assume that m = 1 and q = 1 for every signal. So q+m = 1+1 for every signal each.
  for j = 1:q
    % Create V matrix
    V = zeros((1+1)*p + 1, l-p);
    
    % Begin with the first row for V
    V(1, 1:l-p) = u(j, p+1:l);
    
    % Now do the rest (1+1)*p rows for V. We want to implement v = [u;y] into V - This is equation 8
    positionrow = 1;
    for row = 1:(1+1):(1+1)*p
      % For u
      V(row + 1, 1:l-p) = u(j, p-positionrow+1:l-positionrow);
      % For y
      V(row + 1 + 1, 1:l-p) = y(j, p-positionrow+1:l-positionrow);
      positionrow = positionrow + 1;
    end
    
    % Important to have part of y
    y_part = zeros(1, 1:l-p);
    y_part(1, 1:l-p) = y(j, p+1:l);
    
    % Solve for non-filtred markov parameters with tikhonov regularization
    Ybar = y_part*inv(V'*V + regularization*eye(size(V'*V)))*V';
    
    % Get D matrix
    D = zeros(1, 1);
    D(1,1) = Ybar(1, 1:1); % This is YBar_{-1}
    
    % Remove D from Ybar
    YbarNoD = zeros(1, (1+1)*p);
    YbarNoD(1, 1:(1+1)*p) = Ybar(1, 1+1:(1+1)*p+1);
    
    % Split the signals 
    Ybar1 = zeros(1, p);
    Ybar2 = zeros(1, p);
    Ybar1(1, 1:p) = YbarNoD(1, 1:1+1:(1+1)*p); % C(A+MC)^k(B+MD)
    Ybar2(1, 1:p) = YbarNoD(1, (1+1):1+1:(1+1)*p); % -C(A+MC)^kM
    
    % Get the markov parameters from the signals
    [Yk, Yo] = getMarkov(Ybar1, Ybar2, D, p);
    
    % Store the markov parameters
    CAB(j, 1:p) = Yk(1, 1:p);
    CAM(j, 1:p) = Yo(1, 1:p);
    
  end
  
  % Time to find A, B, C, D using ERA/DC
  sysd = eradc(CAB, sampleTime, delay, systemorder);
  
  % Find the kalman gain matrix K
  O = createO(sysd.A, sysd.C, p/m);
  CAM = CAM(:, 1:size(O, 1));
  K = inv(O'*O)*O'*CAM'; % Our kalman gain matrix

end

% This function will find markov parameters Yk and Yo from Ybar1 and Ybar2
% In this example, we indexing from 1, not 0.
function [Yk, Yo] = getMarkov(Ybar1, Ybar2, D, p)
  Yk = zeros(1, p);
  Yo = zeros(1, p);
  for k = 1:p
    
    % Find the Ybar1 and Ybar2
    Ybar1_k = Ybar1(k);
    Ybar2_k = Ybar2(k);
    
    % Sum
    Ysum = 0;
    Yosum = 0;
    for i = 1:k-1
      Ysum = Ysum + Ybar2(i)*Yk(k-i);
      Yosum = Yosum + Ybar2(i)*Yo(k-i);
    end
  
    % Save for next iteration
    Yk(k) = Ybar1_k + Ysum + Ybar2_k*D; % CA^kB
    Yo(k) = -Ybar2_k + Yosum; % CA^kM
  end
end

% Create the special Observabillity matrix
function PHI = createO(A, C, N)
  PHI = [];
  for i = 1:N
    PHI = vertcat(PHI, C*A^i);
  end
end
