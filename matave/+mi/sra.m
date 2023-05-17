% Stochastic Realization Algorithm
% Input: e(Gaussian noise/disturbance), k(Hankel row length), sampleTime, ktune(kalman tuning, optimal), delay(optional), systemorder(optional)
% Output: sysd(Disturbance model), K(Kalman gain matrix)
% Example 1: [sysd, K] = mi.sra(e, k, sampleTime, ktune);
% Example 2: [sysd, K] = mi.sra(e, k, sampleTime, ktune, delay);
% Example 3: [sysd, K] = mi.sra(e, k, sampleTime, ktune, delay, systemorder);
% Author: Daniel Mårtensson, Oktober 2022

function [sysd, K] = sra(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get impulse response
  if(length(varargin) >= 1)
    e = varargin{1};
  else
    error('Missing gaussian error input')
  end

  % Get k - block rows
  if(length(varargin) >= 2)
    k = varargin{2};
  else
    error('Missing amout of block rows')
  end

  % Get the sample time
  if(length(varargin) >= 3)
    sampleTime = varargin{3};
  else
    error('Missing sample time');
  end

  % Get the ktune
  if(length(varargin) >= 4)
    ktune = varargin{4};
  else
    ktune = 1;
  end

  % Get the delay
  if(length(varargin) >= 5)
    delay = varargin{5};
  else
    delay = 0;
  end

  % Get the order of the system
  if(length(varargin) >= 6)
    systemorder = varargin{6};
    if (systemorder <= 0)
      systemorder = -1;
    end
  else
    systemorder = -1; % If no order was given
  end

  % Strucure the hankel matrix of error outputs
  [p, Ndat] = size(e);
  N = Ndat-2*k;
  j = 0;
  for i = 1:p:2*k*p-p+1
    j = j+1;
    Y(i:i+p-1,:) = e(:,j:j+N-1);
  end

  % Past outputs and future outputs
  Yp = Y(1:k*p,:);
  Yf = Y(k*p+1:2*k*p,:);

  % LQ decomposition - Better to do 1/sqrt(N) after qr() function
  H = [Yp; Yf];
  [Q,L] = qr(H',0);
  L = L'/sqrt(N); % Eq. (8.76)

  L11 = L(1:k*p,1:k*p);
  L21 = L(k*p+1:2*k*p,1:k*p);
  L22 = L(k*p+1:2*k*p,k*p+1:2*k*p);

  % Covariance matrices
  Rff = (L21*L21'+ L22*L22');
  Rfp = L21*L11';
  Rpp = L11*L11';

  % Equation 8.77: Instead of doing cholesky decomposition Rff = L*L^T and Rpp = M*M^T
  [Uf,Sf,Vf] = svd(Rff);
  [Up,Sp,Vp] = svd(Rpp);
  Sf = sqrtm(Sf);
  Sp = sqrtm(Sp);
  L = Uf*Sf*Vf';
  M = Up*Sp*Vp';

  % Do model reduction
  [U,S,V] = svd(inv(L)*Rfp*inv(M)', 'econ');
  [U, S, V, n] = modelReduction(U, S, V, systemorder);

  % Covariance matrix of output
  Lambda = Rpp(1:p,1:p);
  Ok = L*U*sqrtm(S); % Eq. (8.79)
  Ck = sqrtm(S)*V'*M';

  % Create system matrices
  Ad = Ok(1:k*p-p,:) \ Ok(p+1:k*p,:);
  Bd = Ck(:,(k-1)*p + 1:k*p);
  Cd = Ok(1:p,:);
  Dd = zeros(p, p);

  % Create the states
  X = Ck*Yp;
  XX = X(:,2:N);
  X = X(:,1:N-1);
  Y = Yf(1:p,1:N-1);

  % Get noise e and disturbance w
  w = (XX - Ad*X)*ktune;
  e = Y - Cd*X;

  % Computing the covariance matrix
  covariance = cov([w' e']); % Old way = [w*w' w*e'; e*w' e*e']/(N-1);

  % Compute Q, R, S for the riccati equation
  Q = covariance(1:n, 1:n);
  R = covariance(n+1:n+p, n+1:n+p);
  S = covariance(1:n, n+1:n+p);

  % Create a temporary state space model
  riccati = mc.ss(0, Ad', Cd', Bd', Dd');
  riccati.sampleTime = sampleTime;

  % Find kalman filter gain matrix K
  [~, K] = mc.are(riccati, Q, R, S);
  K = K';

  % Create R matrix and then kalman gain K matrix
  %R = Lambda - Cd*S*Cd';
  %K = (Bd' - Ad*S*Cd')/R;

  % Create the model
  sysd = mc.ss(delay, Ad, K, Cd, Dd);
  sysd.sampleTime = sampleTime;

  % Change the reference gain
  sysd = mc.referencegain(sysd);
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
