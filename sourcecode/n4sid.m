% Numerical algorithms for Subspace State Space System IDentification
% Input: u(input signal), y(output signal), k(Hankel row length), sampleTime, ktune(kalman tuning, optimal), delay(optional), systemorder(optional)
% Output: sysd(Discrete state space model), K(Kalman Gain matrix)
% Example 1: [sysd, K] = n4sid(u, y, k, sampleTime);
% Example 2: [sysd, K] = n4sid(u, y, k, sampleTime, ktune);
% Example 3: [sysd, K] = n4sid(u, y, k, sampleTime, ktune, delay);
% Example 4: [sysd, K] = n4sid(u, y, k, sampleTime, ktune, delay, systemorder);
% Author: Daniel Mårtensson, December 2017
% Update: Added system order, Oktober 2022
% Update: Added kalman filter, Januari 2023

function [sysd, K] = n4sid(varargin)
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

  % Get the size of output
  [l,ny] = size(y);
  % Get the size of input
  [m,nu] = size(u);

  % Create the amout of columns
  j = ny-2*k+1;

  % Create hankel matrecies
  U = hank(u, 2*k, j);
  Y = hank(y, 2*k, j);

  % Create the past, future hankel matrecies
  Up = U(1:k*m, :);
  Uf = U((k*m+1):2*k*m, :);

  % For output too.
  Yp = Y(1:k*l,:);
  Yf = Y(k*l+1:2*k*l,:);

  % Get the size of the hankel matrecies
  km = size(Up, 1);
  kl = size(Yp, 1);

  % Create the Wp matrix
  Wp = [Up; Yp];

  % Do QR decomposition
  [R32, R31, R22, R21, R11] = QR([Uf;Up;Yp;Yf], km, kl);

  % Orthogonal projections
  AbC = R32*pinv(R22)*Wp;

  % Do singular value decomposition
  [U,S,V] = svd(AbC, 'econ');

  % Do model reduction
  [U1, S1, V1, nx] = modelReduction(U, S, V, systemorder);

  % Create the observability matrix
  OBSV = U1*sqrtm(S1);

  % Find Cd and Ad from observability matrix
  Cd = OBSV(1:l, 1:nx);
  Ad = pinv(OBSV(1:l*(k-1), 1:nx))*OBSV((l+1):l*k, 1:nx);

  % Find D and B matrix
  DB = (R31 - R32*pinv(R22)*R21)*pinv(R11);

  % Splt up so we first can find Dd and Bd
  DB = DB(:,1:m);

  % This is the same as...
  %DB1 = DB(1*l+1:2*l,:);
  %DB2 = DB(2*l+1:3*l,:);
  %DB3 = DB(3*l+1:4*l,:);
  %DB4 = DB(4*l+1:5*l,:);
  %DB5 = DB(5*l+1:6*l,:);
  %DB6 = DB(6*l+1:7*l,:);
  %DB7 = DB(7*l+1:8*l,:);
  %DB8 = DB(8*l+1:9*l,:);
  %DB9 = DB(9*l+1:10*l,:);
  %CAB = [DB1 DB2 DB3 DB4 DB5;
  %      DB2 DB3 DB4 DB5 DB6;
  %      DB3 DB4 DB5 DB6 DB7;
  %      DB4 DB5 DB6 DB7 DB8;
  %      DB5 DB6 DB7 DB8 DB9]

  % This one...but much dynamical for all types of k, m, l values
  Dd = DB(1:l,:); % D-matrix
  DB = DB(l+1:end, :);
  a = floor((k*l-l)/2) + 1;
  k = floor(k/2);
  Hankel_CAB = [DB(1:a, :)];
  for i = 1:k-1
    Hankel_CAB = [Hankel_CAB DB(i*l+1:a+i*l,:)]; % Place all CAB files here. We want to find B-matrix
  end

  % Extract ony the CAB...CA^kB parts of DB
  CAB_OBSV = OBSV(1:size(Hankel_CAB, 1),:);

  % Create the controllability matrix
  CTRB = pinv(CAB_OBSV)*Hankel_CAB;

  % Find Bd matrix now
  Bd = CTRB(:, 1:m);

  % Create the state space model
  sysd = ss(delay, Ad, Bd, Cd, Dd);
  sysd.sampleTime = sampleTime;

  % Create kalman filter
  x = zeros(size(Ad, 1), 1);
  for k = 1:size(u, 2)
    xhat(:,k) = x; % Save the states
    yhat(:,k) = Cd*x + Dd*u(:,k);
    x = Ad*x + Bd*u(:,k); % Update state vector
  end

  % Find the real states
  x = Cd\(y-Dd*u);

  % Find the noise
  e = y - yhat;

  % Find the disturbance
  w = (x - xhat)*ktune;

  % Computing the covariance matrix
  covariance = cov([w' e']); % Old way = [w*w' w*e'; e*w' e*e']/(N-1);

  % Compute Q, R, S for the riccati equation
  Q = covariance(1:nx, 1:nx);
  R = covariance(nx+1:nx+l, nx+1:nx+l);
  S = covariance(1:nx, nx+1:nx+l);

  % Create a temporary state space model
  riccati = ss(0, Ad', Cd', Bd', Dd');
  riccati.sampleTime = sampleTime;

  % Find kalman filter gain matrix K
  [~, K] = are(riccati, Q, R, S);
  K = K';

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

function [R32, R31, R22, R21, R11] = QR(A, km, kl)
  % QR
  [Q,L] = qr(A',0);

  % Transpose so A = L*Q
  Q=Q';
  L=L';

  % Split
  L11 = L(1:km, 1:km);
  L21 = L(km+1:2*km, 1:km);
  L22 = L(km+1:2*km, km+1:2*km);
  L31 = L(2*km+1:2*km+kl, 1:km);
  L32 = L(2*km+1:2*km+kl, km+1:2*km);
  L33 = L(2*km+1:2*km+kl, 2*km+1:2*km+kl);
  L41 = L(2*km+kl+1:2*km+2*kl, 1:km);
  L42 = L(2*km+kl+1:2*km+2*kl, km+1:2*km);
  L43 = L(2*km+kl+1:2*km+2*kl, 2*km+1:2*km+kl);
  L44 = L(2*km+kl+1:2*km+2*kl, 2*km+kl+1:2*km+2*kl);

  R11 = L11;
  R21 = [L21; L31];
  R22 = [L22 zeros(km,kl); L32 L33];
  R31 = L41;
  R32 = [L42 L43];
end

function [H] = hank(g, i, j)
  % Get size
  l = size(g, 1);
  % Create a large hankel matrix
  H = zeros(l*i,j);

  for k=1:i
    H((k-1)*l+1:k*l,:) = g(:,k:k+j-1);
  end

end
