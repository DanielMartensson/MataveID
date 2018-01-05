% Ho-Kalman algorithm which was extended by Kung
% Identify the discrete state space model from a impulse response.
% Input: g(markov parameters), nu(number of inputs), sampleTime, delay(optional)
% Output: sysd(Discrete state space model)
% Example 1: [sysd] = hokalman(g, nu, sampleTime, delay);
% Author: Daniel Mårtensson, December 2017

function [sysd] = hokalman(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
  end
  
  % Get impulse response
  if(length(varargin) >= 1)
    g = varargin{1};
  else
    error('Missing impulse response')
  end
  
  % Get number of inputs
  if(length(varargin) >= 2)
    nu = varargin{2};
  else
    error('Missing number of inputs')
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
  
  % Check if g can be diveded with 2
  if mod(length(g), 2) > 0
    error('The output cannot be divided with 2')
  end
  
  % Create hankel matrix
  H = hank(g, 1); 
  
  % Do singular value decomposition
  [U, S, V] = svd(H, 'econ');
  
  % Do model reduction
  [Un, Sn, Vn, nx] = modelReduction(U, S, V);
  
  % Create extended matrices
  OBSV = Un*sqrtm(Sn);
  CTRB = sqrtm(Sn)*Vn';
  
  % Get numbers of outputs, we already know nx and nu
  ny = size(g, 1); 
  
  % Get matrices
  Cd = OBSV(1:ny, :);
  Ad = pinv(OBSV(1:end-ny, :))*OBSV((1+ny):end, :);
  Bd = CTRB(:, 1:nu);
  
  % Create state space model now
  sysd = ss(delay, Ad, Bd, Cd); % Dn will be 0
  sysd.sampleTime = sampleTime;
end

function [H] = hank(g, k)
  % Create hankel matrix
  H = cell(length(g)/2,length(g)/2); 
  
  for i = 1:length(g)/2
    for j = 1:length(g)/2
      H{i,j} = g(:,k+i+j-2);
    end
  end
  
  % Cell to matrix
  H = cell2mat(H);
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