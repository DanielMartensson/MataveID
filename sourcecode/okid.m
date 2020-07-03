% Observer Kalman Filter Identification
% Input: u(input signal), y(output signal), sampleTime, delay(optional), regularization(optional), systemorder(optional)
% Output: sysd(Discrete state space model), K(Kalman gain matrix)
% Example 1: [sysd, K] = okid(u, y, sampleTime, modelorderTF, forgetting, systemorder);
% Example 2: [sysd, K] = okid(u, y, sampleTime, systemorderTF);
% Author: Daniel Mårtensson, December 2017
% Update January 2019 - Better hankel matrix that fix the 1 step delay.
% Update 26 April 2020 - For MIMO data and follows NASA document ID 19910016123
% Update 3 June 2020 - Connecting RLS with OKID for more stable estimation due to noise

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
  
  % Get the model order for the transfer function
  if(length(varargin) >= 4)
    systemorderTF = varargin{4};
  else
    error('Missing model order');
  end
  
  % Get the forgetting
  if(length(varargin) >= 5)
    forgetting = varargin{5};
  else
    forgetting = 1; % If no forgetting was given
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
  
  % Data dimensions
  impulseTime = 10; % You might want to change this if you have slow impulse response 
  p = impulseTime/sampleTime*2;
  P = zeros(q, p+p);
  
  % Find the CA^kB and CA^kM parameters
  for j = 1:q
    [sysd, K] = rls(u(j, :), y(j, :), systemorderTF, systemorderTF, systemorderTF, sampleTime, forgetting); % RLS is a perfect choice in this noisy case
    Yk = impulse(sysd, impulseTime);
    close % A pop up plot will appear from impulse.m
    Yk = Yk(1:2:length(Yk)); % Remove the discrete shape - Only necessary for plotting! In this case...no.
    sysd.B = K; % Replace input matrix B with kalman gain matrix K. In OKID case, M = K
    Yo = impulse(sysd, impulseTime);
    close
    Yo = Yo(1:2:length(Yo));
    index = 1;
    for i = 1:2:p
      P(j, i:i+1) = [Yk(index) Yo(index)];
      index = index + 1;
    end
  end
  
  % Create A, B, C, D and K from one SVD computation. P = [CA^kB, CA^kM] = [Yk Yo]; One markov parameter, even if it's rectangular.
  delay = 0;
  [sysd, K] = eradcokid(P, sampleTime, delay, systemorder);
   
end

% Special ERA/DC for just OKID command.
% This is equation 29 in OKID.pdf file. Read also ERADC.pdf file as well
function [sysd, K] = eradcokid(g, sampleTime, delay, systemorder)
  % Get the number of input
  nu = size(g, 1); 
  
  % Change g for MIMO to diagonal case
  if(nu > 1) 
    l = length(g);
    G = zeros(nu, l*nu); 
    beginning = 1;
    for i = 1:nu
      Gcolumn = beginning; % Where we should start. 1 to begin with
      columncount = 1;
      for j = 1:l
        
        % Insert data into G and count
        G(i, Gcolumn) = g(i, j);
        Gcolumn = Gcolumn + 1;
        columncount = columncount + 1;
        
        % When we av inserted [CAB CAM] then jump two steps to right
        if(columncount > 2)
          columncount = 1;
          Gcolumn = Gcolumn + 2;
        end
        
      end
      
      % This counter is made for the shifting so G will be diagonal
      beginning = beginning + 2;
    end
    g = G; 
  end
  
  % Create hankel matrices 
  H0 = hank(g, 1);
  H1 = hank(g, 2);
  
  % Do data correlations
  R0 = H0*H0';
  R1 = H1*H0';
  
  % Do SVD on R0
  [U,S,V] = svd(R0, 'econ');
  
  % Do model reduction
  [Un, En, Vn, nx] = modelReduction(U, S, V, systemorder);
  
  % Create the A matrix
  Ad = En^(-1/2)*Un'*R1*Vn*En^(-1/2);
  
  % The reason why we are using 1:2:nu*2 and 2:2:nu*2 here is because how
  %   P = [CAB CAM];
  %   Is shaped. Try to understand how I have placed the data in P.
  %   P(j, i:i+1) = [Yk(index) Yo(index)];
  %  
  %   Example for the impulse response
  %         1     2     3    4     5   6   nu
  %  1 g = [CAB1 CAM1   0    0     0   0
  %  2       0     0   CAB2 CAM2   0   0
  %  3       0     0    0    0   CAB3 CAM3];
  %  nu
  
  % From X we can get Bd and K(Kalman gain M)
  Pa = Un*En^(1/2);
  X = pinv(Pa)*H0; 
  Bd = X(1:nx, 1:2:nu*2);
  K = X(1:nx, 2:2:nu*2);
  
  % From Pa we can find Cd
  Cd = Pa(1:nu, 1:nx);
  
  % D matrix
  Dd = g(1:nu, 1:2:nu*2);

  % Create state space model now
  sysd = ss(delay, Ad, Bd, Cd, Dd);
  sysd.sampleTime = sampleTime;
  
end

function [U1, S1, V1, nx] = modelReduction(U, S, V, systemorder)
  % Plot singular values 
  stem(1:length(S), diag(S));
  title('Hankel Singular values');
  xlabel('Amount of singular values');
  ylabel('Value');
  
  if(systemorder == -1)
    % Choose system dimension n - Remember that you can use modred.m to reduce some states too!
    nx = inputdlg('Choose the state dimension by looking at hankel singular values: ');
    nx = str2num(cell2mat(nx));
  else
    nx = systemorder;
  end
  
  % Choose the dimension nx
  U1 = U(:, 1:nx);
  S1 = S(1:nx, 1:nx);
  V1 = V(:, 1:nx);
end

% Create the half square hankel matrix - Special case for OKID: Pk = [CA^kB CA^kM]; = Rectangular
function [H] = hank(g, k)
  % We got markov parameters g = [g0 g1 g2 g2 g3 ... gl]; with size m*(2*m). g0 = D
  m = size(g, 1);
  if(m == 1) % SISO
    l = length(g)/2;
    H = zeros(l/2, l);
    for i = 1:l/2
        if(k*2 + (i-1)*2 + l > length(g))
          empty = k*2 + (i-1)*2 + l - length(g);
          H(i, 1:l) = [g(m, 1 + k*2 + (i-1)*2: k*2 + (i-1)*2 + l - empty) zeros(1, empty)]; % If k >= 2
        else
          H(i, 1:l) = g(m, 1 + k*2 + (i-1)*2: k*2 + (i-1)*2 + l);
        end
    end
  else % MIMO
    l = length(g)/(m*2);
    H = zeros(l/2, l*m);
    for i = 1:l/2
      if(k*2*m + (i-1)*2*m + l*m > length(g))
        empty = k*2*m + (i-1)*2*m + l*m - length(g);
        H(1 + (i-1)*m:(i-1)*m + m, 1:l*m) = [g(1:m, 1 + k*2*m + (i-1)*2*m: k*2*m + (i-1)*2*m + l*m - empty) zeros(m, empty)]; % If k >= 2
      else
        H(1 + (i-1)*m:(i-1)*m + m, 1:l*m) = g(1:m, 1 + k*2*m + (i-1)*2*m: k*2*m + (i-1)*2*m + l*m);
      end
    end
  end
end
