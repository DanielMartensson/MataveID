% Multivariable Output-Error State Space
% Input: u(input signal), y(output signal), k(Hankel row length), sampleTime, delay(optional), systemorder(optional)
% Output: sysd(Discrete state space model)
% Example 1: [sysd] = moesp(u, y, k, sampleTime);
% Example 2: [sysd] = moesp(u, y, k, sampleTime, delay);
% Example 3: [sysd] = moesp(u, y, k, sampleTime, delay, systemorder);
% Author: Daniel Mårtensson, Oktober 2022

function [sysd] = moesp(varargin)
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

  % Get the order of the system
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

  % Get number of inputs and outputs
  nu = size(u, 1);
  ny = size(y, 1);

  % Block Hankel matrix
  N = length(u) - k + 1;
  Y = zeros(k*ny, N);
  U = zeros(k*nu, N);
  sN = sqrt(N);
  sy = y/sN;
  su = u/sN;
  for s=1:k
      Y((s-1)*ny+1:s*ny,:) = sy(:,s:s+N-1);
      U((s-1)*nu+1:s*nu,:) = su(:,s:s+N-1);
  end

  % LQ decomposition
  R = triu(qr([U;Y]'))';
  R = R(1:k*(ny+nu),:);

  % SVD
  R22 = R(k*nu+1:end,k*nu+1:end);
  [U1,S1] = svd(R22, 'econ');

  % Do model reduction
  n = modelReduction(S1, systemorder);

  % Divide with \ might give a matrix singular to machine precision.
  % But \ is more accurate than finding the inverse or pseudo.
  % So we close the warnings instead
  warning('off');

  % Find A and C
  Ok = U1(:,1:n)*sqrt(S1(1:n, 1:n));
  A = Ok(1:ny*(k-1),:) \ Ok(ny+1:k*ny,:);
  C = Ok(1:ny,:);

  % Prepare to find B and D
  L1 = U1(:,n+1:end)';
  R11 = R(1:k*nu,1:k*nu);
  R21 = R(k*nu+1:end,1:k*nu);
  M1 = L1*R21/R11;
  m = ny*k - n;
  M = zeros(m*k,nu);
  L = zeros(m*k,ny+n);

  % Do linear regression for finding B and D
  for k = 1:k
    M((k-1)*m+1:k*m,:) = M1(:,(k-1)*nu+1:k*nu);
    L((k-1)*m+1:k*m,:) = [L1(:,(k-1)*ny+1:k*ny) L1(:,k*ny+1:end)*Ok(1:end-k*ny,:)];
  end
  DB = L\M;
  B = DB(ny+1:end,:);
  D = DB(1:ny,:);

  % Create the model
  sysd = ss(0, A, B, C, D);
  sysd.sampleTime = sampleTime;
end

function [nx] = modelReduction(S, systemorder)
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