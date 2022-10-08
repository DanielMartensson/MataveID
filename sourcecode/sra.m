% Stochastic Realization Algorithm
% Input: e(Error with gaussian distribution), k(Hankel row length), sampleTime, systemorder(optional)
% Output: H(ARMA model)
% Example 1: [H] = sra(e, k, sampleTime);
% Example 2: [H] = sra(e, k, sampleTime, systemorder);
% Author: Daniel Mårtensson, Oktober 2022

function [H] = sra(varargin)
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

  % Get the order of the system
  if(length(varargin) >= 4)
    systemorder = varargin{4};
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

  Lambda = Rpp(1:p,1:p); % Covariance matrix of output
  Ok = L*U*sqrtm(S); % Eq. (8.79)
  Ck = sqrtm(S)*V'*M';
  Ad = Ok(1:k*p-p,:) \ Ok(p+1:k*p,:);
  Cd = Ok(1:p,:);
  Bd = Ck(:,(k-1)*p+1:k*p)';
  R = Lambda-Cd*S*Cd';
  K = (Bd'-Ad*S*Cd')/R;

  % Create the model
  sysd = ss(0, Ad, K, Cd, zeros(p, p));
  sysd.sampleTime = sampleTime;

  % Get poles, zeros and gain to build state space to ARMA
  p = pole(sysd);
  [z, gain] = tzero(sysd);

  % Get the numerators and denomerators
  zeros_poles_gain = zpk(z, p, gain);
  num = zeros_poles_gain.num;
  den = zeros_poles_gain.den;
  H = arma(num, den);
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
