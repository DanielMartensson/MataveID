% Canoncial Correlation Analysis
% Input: u(input signal), y(output signal), k(Hankel row length), sampleTime, delay(optional)
% Output: sysd(Discrete state space model), K(Kalman Gain matrix), R(Noise matrix), Q(Disturbance matrix) 
% Example 1: [sysd, K, R, Q] = n4sid(u, y, k, sampleTime, delay);
% Example 2: [sysd, K, R, Q] = n4sid(u, y, k, sampleTime);
% Author: Daniel Mårtensson, September 2022

function [sysd, K, R, Q] = cca(varargin)
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

  % Get the delay
  if(length(varargin) >= 5)
    delay = varargin{5};
  else
    delay = 0; % If no delay was given
  end

  % Check if u and y has the same length
  if(length(u) ~= length(y))
    error('Input(u) and output(y) has not the same length')
  end

  % Get the size of y and u
  [p,Ndat] = size(y);
  [m,Ndat] = size(u);

  % Compute two data matricies
  N = Ndat-2*k;
  j = 0;
  for i = 1:m:2*k*m-m+1
    j = j+1;
    U(i:i+m-1,:) = u(:,j:j+N-1);
  end
  j = 0;
  for i = 1:p:2*k*p-p+1
    j = j+1;
    Y(i:i+p-1,:) = y(:,j:j+N-1);
  end

  % Compute the future signals
  Uf = U(k*m+1:2*k*m,:);
  Yf = Y(k*p+1:2*k*p,:);

  % Compute the past signals
  Up = U(1:k*m,:);
  Yp = Y(1:k*p,:);
  Wp = [Up; Yp];

  % Do LQ decomposition
  H = [Uf; Up; Yp; Yf];
  [Q,L] = qr(H',0);
  L = L';

  % Extract the L matrix to different matricies
  L22 = L(k*m+1:k*(2*m+p),k*m+1:k*(2*m+p));
  L32 = L(k*(2*m+p)+1:2*k*(m+p),k*m+1:k*(2*m+p));
  L33 = L(k*(2*m+p)+1:2*k*(m+p),k*(2*m+p)+1:2*k*(m+p));
  Rff = L32*L32' + L33*L33';
  Rpp = L22*L22';
  Rfp = L32*L22';

  % Do SVD for pesudo inverse
  [Uff,Sf,Vf] = svd(Rff);
  [Up,Sp,Vp] = svd(Rpp);
  Sf = sqrtm(Sf);
  Sfi = inv(Sf);
  Sp = sqrtm(Sp);
  Spi = inv(Sp);
  Lfi = Vf*Sfi*Uff';
  Lpi = Vp*Spi*Up';
  OC = Lfi*Rfp*Lpi';

  % Compute the singular values from OC
  [UU,SS,VV] = svd(OC, 'econ');

  % Do model reduction
  [U1, S1, V1, n] = modelReduction(UU, SS, VV);

  % Find A, B, C, D as one matrix
  X = sqrtm(S1)*V1'*Lpi*Wp;
  XX = X(:,2:N);
  X = X(:,1:N-1);
  U = Uf(1:m,1:N-1);
  Y = Yf(1:p,1:N-1);
  ABCD = [XX; Y]/[X; U];

  % Extract A, B, C, D matrices from ABCD
  Ad = ABCD(1:n,1:n);
  Bd = ABCD(1:n,n+1:n+m);
  Cd = ABCD(n+1:n+p,1:n);
  Dd = ABCD(n+1:n+p,n+1:n+m);

  % Create state space model now
  delay = 0;
  sysd = ss(delay, Ad, Bd, Cd, Dd);
  sysd.sampleTime = sampleTime;

  % Get noise and disturbance
  W = XX - Ad*X - Bd*U;
  E = Y - Cd*X - Dd*U;

  % Computing the covariance matrix
  covariance = [W*W' W*E'; E*W' E*E']/(N-1);

  % Compute Q, R, S for the riccati equation
  Q = covariance(1:n, 1:n);
  R = covariance(n+1:n+p, n+1:n+p);
  S = covariance(1:n, n+1:n+p);

  % Create a temporary state space model
  delay = 0;
  riccati = ss(delay, Ad', Cd', Bd', Dd');
  riccati.sampleTime = sampleTime;

  % Find kalman filter gain matrix K
  [X, K, L] = are(riccati, Q, R, S);
  K = L';
end

function [U1, S1, V1, nx] = modelReduction(U, S, V)
  % Plot singular values
  stem(1:length(S), diag(S));
  title('Hankel Singular values');
  xlabel('Amount of singular values');
  ylabel('Value');

  % Choose system dimension n - Remember that you can use modred.m to reduce some states too!
  nx = inputdlg('Choose the state dimension by looking at hankel singular values: ');
  nx = str2num(cell2mat(nx));

  % Choose the dimension nx
  U1 = U(:, 1:nx);
  S1 = S(1:nx, 1:nx);
  V1 = V(:, 1:nx);
end


