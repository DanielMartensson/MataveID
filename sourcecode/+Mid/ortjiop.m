% Orthogonal Decomposition of Joint Input-Output Process
% Input: u(input signal), y(output signal), r(reference), d(input disturbance), k(Hankel row length), sampleTime, delay(optional), systemorder(optional)
% Output: sysd(closed loop model), P(plant model), C(controller model)
% Example 1: [sysd, P, C] = Mid.ortjiop(u, y, r, d, k, sampleTime);
% Example 2: [sysd, P, C] = Mid.ortjiop(u, y, r, d, k, sampleTime, delay);
% Example 3: [sysd, P, C] = Mid.ortjiop(u, y, r, d, k, sampleTime, delay, systemorder);
% Author: Daniel Mårtensson, Oktober 26:e 2022. Following page 314 from Subspace Methods for System Identification, ISBN-10: 1852339810
% Closed loop:
% x(k+1) = Ax(k) + B[r(k); d(k)]
% [y(k);u(k)] = Cx(k) + D[r(k); d(k)]
% Plant model:
% x(k+1) = (A - B2*inv(D22)*C2)x + B2*inv(D22)*u
% y(k) = C1*x + 0*u
% Controller model:
% x(k+1) = (A - B2*inv(D22)*C2)x + (B1 - B2*inv(D22)*D21)*u
% y(k) = inv(D22)*C2*x + inv(D22)*D21*u

function [sysd, P, C] = ortjiop(varargin)
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

  % Get reference
  if(length(varargin) >= 3)
    r = varargin{3};
  else
    error('Missing reference')
  end

  % Get input disturbance
  if(length(varargin) >= 4)
    d = varargin{4};
  else
    error('Missing input disturbance')
  end

  % Get k - block rows
  if(length(varargin) >= 5)
    k = varargin{5};
  else
    error('Missing amout of block rows')
  end

  % Get the sample time
  if(length(varargin) >= 6)
    sampleTime = varargin{6};
  else
    error('Missing sample time');
  end

  % Get the delay
  if(length(varargin) >= 7)
    delay = varargin{7};
  else
    delay = 0; % If no delay was given
  end

  % Get the order of the system
  if(length(varargin) >= 8)
    systemorder = varargin{8};
    if (systemorder <= 0)
      systemorder = -1;
    end
  else
    systemorder = -1; % If no order was given
  end

  % Get the size of u
  [m, Ndat] = size(u);

  % Check size
  if(Ndat ~= size(u, 2))
    error('The length of y need to be the same as u');
  end

  % Get size of y
  [p, Ndat] = size(y);

  % Check size
  if(p ~= size(r, 1))
    error('The dimension of y need to be the same as r');
  elseif(Ndat ~= size(r, 2))
    error('The length of y need to be the same as r');
  end

  % Check size
  if(m ~= size(d, 1))
    error('The dimension of u need to be the same as d');
  elseif(Ndat ~= size(d, 2))
    error('The length of u need to be the same as d');
  end

  % Compute N, v and w
  N = Ndat - 2*k;
  v = [r;d];
  w = [y;u];

  % Get past: Vp, Wp
  Vp = getPast(v, k, N);
  Wp = getPast(w, k, N);

  % Get future: Vf, Wf
  Vf = getFuture(v, k, N);
  Wf = getFuture(w, k, N);

  % Do LQ decomposition
  H = [Vf; Vp; Wp; Wf];
  [Q,L] = qr(H',0);
  L = L';

  % Get L11, L41, L42
  L11 = L(1:k*(m+p), 1:k*(m+p));
  L41 = L(3*k*(p+m)+1:end, 1:k*(m+p));
  L42 = L(3*k*(p+m)+1:end, k*(p+m)+1:2*k*(p+m));

  % Do SVD on L42
  [U, S, V] = svd(L42, 'econ');

  % Do model reduction
  [n] = modelReduction(U, S, V, systemorder);

  % Observability matrix
  Ok = U(:, 1:n)*sqrtm(S(1:n, 1:n));

  % Get C
  C = Ok(1:p+m, 1:n);

  % Get A
  A = pinv(Ok(1:(p+m)*(k-1), 1:n))*Ok(p+m+1:k*(p+m), 1:n);

  % Get B and D
  U2 = U(:,n+1:size(U',1));
  Z = U2'*L41/L11;
  XX = [];
  RR = [];
  for j = 1:k
    XX = [XX; Z(:,(p+m)*(j-1)+1:(p+m)*j)];
    Okj = Ok(1:(p+m)*(k-j),:);
    Rj = [zeros((p+m)*(j-1),p+m),zeros((p+m)*(j-1),n);
          eye(p+m), zeros(p+m,n);
          zeros((p+m)*(k-j),p+m),Okj];
    RR = [RR;U2'*Rj];
  end
  DB = pinv(RR)*XX;
  D = DB(1:p+m,:);
  B = DB(p+m+1:size(DB,1),:);

  % Create the closed loop
  sysd = mc.ss(delay, A, B, C, D);
  sysd.sampleTime = sampleTime;

  % Split up B, C, D
  B1 = B(:, 1:m);
  B2 = B(:, m+1:m+p);
  C1 = C(1:p, :);
  C2 = C(p+1:m+p, :);
  D11 = D(1:p, 1:m);
  D12 = D(1:p, m+1:m+p);
  D21 = D(p+1:m+p, 1:m);
  D22 = D(p+1:m+p, m+1:m+p);

  % Create plant model
  Ad = A - B2*inv(D22)*C2;
  Bd = B2*inv(D22);
  Cd = C1;
  Dd = zeros(p, m);
  P = mc.ss(delay, Ad, Bd, Cd, Dd);
  P.sampleTime = sampleTime;

  % Create controller model
  Ad = A - B2*inv(D22)*C2;
  Bd = B1 - B2*inv(D22)*D21;
  Cd = inv(D22)*C2;
  Dd = inv(D22)*D21;
  C = mc.ss(delay, Ad, Bd, Cd, Dd);
  C.sampleTime = sampleTime;
end

function P = getPast(A, k, N)
  % Get past matrix
  P = A(:, 1:N);
  j = 1;
  for i = 2:k
    P = [P; A(:, i:N+j)];
    j = j + 1;
  end
end

function F = getFuture(A, k, N)
  % Get future matrix
  F = A(:, 1+k:N+k);
  j = 1;
  for i = 1+k:2*k-1
    F = [F; A(:, 1+i:N+k+j)];
    j = j + 1;
  end
end

function [nx] = modelReduction(U, S, V, systemorder)
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
end
