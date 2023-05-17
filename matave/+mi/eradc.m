% Eigensystem Realization Algorithm with Data Correlation
% Input: g(markov parameters/impulse response), sampleTime, ktune(kalman tuning, optimal), delay(optional), systemorder(optional)
% Output: sysd(Discrete state space model), K(Kalman Gain matrix)
% Example 1: [sysd, K] = Mid.eradc(g, sampleTime);
% Example 2: [sysd, K] = Mid.eradc(g, sampleTime, ktune);
% Example 3: [sysd, K] = Mid.eradc(g, sampleTime, ktune, delay);
% Example 4: [sysd, K] = Mid.eradc(g, sampleTime, ktune, delay, systemorder);
% Author: Daniel Mårtensson, November 2017
% Update: 20 April 2020 - For MIMO hankel. Follows the NASA document ID 19870035963
% Update: Added kalman filter, Januari 2023

function [sysd, K] = eradc(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get impulse response
  if(length(varargin) >= 1)
    g = varargin{1};
  else
    error('Missing impulse response')
  end

  % Get the sample time
  if(length(varargin) >= 2)
    sampleTime = varargin{2};
  else
    error('Missing sample time');
  end

  % Get the kalman filter tuning
  if(length(varargin) >= 3)
    ktune = varargin{3};
  else
    ktune = 1;
  end

  % Get the delay
  if(length(varargin) >= 4)
    delay = varargin{4};
  else
    ktune = 0;
  end

  % Get the order of the system
  if(length(varargin) >= 5)
    systemorder = varargin{5};
    if (systemorder <= 0)
      systemorder = -1;
    end
  else
    systemorder = -1; % If no order was given
  end

  % Check if g can be diveded with 2
  if mod(length(g), 2) > 0
    g = g(:, 1:end-1);
  end

  % Get the number of input
  nu = size(g, 1);

  % Change g for MIMO to diagonal case
  if(nu > 1)
    l = length(g);
    G = zeros(nu, l*nu);
    for i = 1:nu
      G(i, i:nu:l*nu-1+i) = g(i, 1:l);
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

  % Create scalar for Bb, Cd
  ny = size(g, 1); % Number of outputs, we already know the number of inputs
  gamma = size(H0, 1); % Get the row size of H0 - This one is a special case for ERA/DC
  Er = [eye(gamma) zeros(gamma,size(En^(1/2)*Vn',2) - size(eye(gamma),2))]';
  Ey = [eye(ny) zeros(ny,size(Un*En^(1/2),1) - size(eye(ny),1))]';
  Eu = [eye(nu) zeros(nu,size(pinv(Er'*Un*En^(1/2))*H0,2) - size(eye(nu),2))]';

  % Create matrix - Notice the change
  Ad = En^(-1/2)*Un'*R1*Vn*En^(-1/2);
  Bd = pinv(Er'*Un*En^(1/2))*H0*Eu;
  Cd = Ey'*Un*En^(1/2);
  Dd = g(1:ny, 1:nu);

  % Create state space model now
  sysd = mc.ss(delay, Ad, Bd, Cd, Dd);
  sysd.sampleTime = sampleTime;

  % Create kalman filter
  x = zeros(size(Ad, 1), 1);
  u = zeros(size(g));
  u(:, 1) = 1;
  for k = 1:size(u, 2)
    xhat(:,k) = x; % Save the states
    ghat(:,k) = Cd*x + Dd*u(:,k);
    x = Ad*x + Bd*u(:,k); % Update state vector
  end

  % Find the real states
  x = Cd\(g-Dd*u);

  % Find the noise
  e = g - ghat;

  % Find the disturbance
  w = (x - xhat)*ktune;

  % Computing the covariance matrix
  covariance = cov([w' e']); % Old way = [w*w' w*e'; e*w' e*e']/(N-1);

  % Compute Q, R, S for the riccati equation
  Q = covariance(1:nx, 1:nx);
  R = covariance(nx+1:nx+ny, nx+1:nx+ny);
  S = covariance(1:nx, nx+1:nx+ny);

  % Create a temporary state space model
  riccati = mc.ss(0, Ad', Cd', Bd', Dd');
  riccati.sampleTime = sampleTime;

  % Find kalman filter gain matrix K
  [~, K] = mc.are(riccati, Q, R, S);
  K = K';
end

% Create the half square hankel matrix
function [H] = hank(g, k)
  % We got markov parameters g = [g0 g1 g2 g2 g3 ... gl]; with size m*m. g0 = D
  m = size(g, 1);
  n = size(g, 2);
  l = length(g)/(m*2);
  H = zeros(l*m, l*m);
  for i = 1:l
    if(and(i == l, k == 2))
      % This is a special case when g is out of index, just add zeros instead!
      row = g(:, 1 + (k+i-1)*m:(k+i-2)*m + l*m);
      H(1 + (i-1)*m:(i-1)*m + m, 1:l*m) = [row zeros(m, m)];
   else
      row = g(:, 1 + (k+i-1)*m:(k+i-1)*m + l*m);
      H(1 + (i-1)*m:(i-1)*m + m, 1:l*m) = row;
    end
  end
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
