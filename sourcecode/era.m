% Eigensystem Realization Algorithm 
% Input: g(markov parameters), nu(number of inputs), sampleTime, delay(optional), systemorder(optional)
% Output: sysd(Discrete state space model)
% Example 1: [sysd] = era(g, nu, sampleTime, delay, systemorder);
% Author: Daniel Mårtensson, November 2017
% Update January 2019 - Better hankel matrix that fix the 1 step delay.
% Update 20 April 2020 - For MIMO hankel. Follows the NASA document ID 19850022899

function [sysd] = era(varargin)
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
  
  % Get the number of input
  if(length(varargin) >= 2)
    nu = varargin{2};
  else
    error('Missing number of input');
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
    error('The output cannot be divided with 2')
  end
  
  % Change g for MIMO to diagonal case
  if(nu > 1)
    l = length(g);
    G = zeros(nu, l*nu);
    for i = 1:nu
      G(i, i:nu:l*nu-1+i) = g(i, 1:l);
    end
    g = G; 
  end

  % Create hankel matrecies
  H0 = hank(g, 1);
  H1 = hank(g, 2);
  
  % Do SVD on H0
  [U,S,V] = svd(H0, 'econ');
  
  % Do model reduction
  [Un, En, Vn, nx] = modelReduction(U, S, V, systemorder);
  
  % Create scalar for Bb, Cd
  ny = size(g, 1); % Number of outputs, we already know the number of inputs
  Ey = [eye(ny) zeros(ny,size(Un*En^(1/2),1) - size(eye(ny),1))]';
  Eu = [eye(nu) zeros(nu,size(En^(1/2)*Vn',2) - size(eye(nu),2))]';
  
  % Create matrix
  Ad = En^(-1/2)*Un'*H1*Vn*En^(-1/2);
  Bd = En^(1/2)*Vn'*Eu;
  Cd = Ey'*Un*En^(1/2);
  Dd = g(1:ny, 1:nu);
  
  % Create state space model now
  sysd = ss(delay, Ad, Bd, Cd, Dd);
  sysd.sampleTime = sampleTime;
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
