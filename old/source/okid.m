% Observer Kalman Filter Identification
% Input: u(input signal), y(output signal), sampleTime, delay(optional), regularization(optional), systemorder(optional)
% Output: sysd(Discrete state space model), K(Kalman gain matrix)
% Example 1: [sysd, K] = okid(u, y, sampleTime, regularization, systemorder);
% Example 2: [sysd, K] = okid(u, y, sampleTime);
% Author: Daniel Mårtensson, December 2017
% Update January 2019 - Better hankel matrix that fix the 1 step delay.
% Update 26 April 2020 - For MIMO data and follows NASA document ID 19910016123

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
  
  % Get the regularization parameter
  if(length(varargin) >= 4)
    regularization = varargin{4};
    if (regularization <= 0)
      regularization = 0;
    end
  else
    regularization = 0; % If no regularization was given
  end
  
  % Get the order if the system
  if(length(varargin) >= 5)
    systemorder = varargin{5};
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
  
  % Check if y and u can be diveded with 2
  if mod(length(u), 2) > 0
    u = u(:, 1:end-1);
    y = y(:, 1:end-1);
  end
  
  % Get the dimensions first
  q = size(y, 1); % Dimension of output
  l = size(y, 2); % Total length
  m = size(u, 1); % Dimension of input
  p = l/2-1; % We select half minus -1 else Ybar can be unstable for noise free case. 
  % If you going to estimate K by the experimental way, set p = l/2-1 to p = l/2. Else, you will not get correct indexing for O matrix down there.
  
  % Save the system markov parameters and observer markov parameters here
  CAB = zeros(q, p);
  CAM = zeros(q, p);
  P = zeros(q, p+p);
  
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
    
    % Store the markov parameters - Experimental!
    CAB(j, 1:p) = Yk(1, 1:p);
    CAM(j, 1:p) = Yo(1, 1:p);
    
    % Save them into one markov parameter P 
    index = 1;
    for i = 1:2:2*p
      P(j, i:i+1) = [Yk(index) Yo(index)];
      index = index + 1;
    end
    
  end
  
  % Create A, B, C, D and K from one SVD computation. P = [CA^kB, CA^kM]; One markov parameter, even if it's rectangular.
  delay = 0;
  [sysd, K] = eradcokid(P, sampleTime, delay, systemorder);
  
  % Time to find A, B, C, D using ERA/DC - Experimental!
  %sysd = eradc(CAB, sampleTime, delay, systemorder);
  
  % Find the kalman gain matrix K - Experimental!
  %O = createO(sysd.A, sysd.C, p/m);
  %K = inv(O'*O)*O'*CAM'; % Our kalman gain matrix
   
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

% Create the half square hankel matrix - Special case for OKID: Pk = [CA^kB CA^k]; = Rectangular
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
  for i = 0:N-1
    PHI = vertcat(PHI, C*A^i);
  end
end
