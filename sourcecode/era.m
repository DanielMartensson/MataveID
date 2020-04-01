% Eigensystem Realization Algorithm 
% Input: g(markov parameters), nu(number of inputs), sampleTime, delay(optional)
% Output: sysd(Discrete state space model)
% Example 1: [sysd] = era(g, nu, sampleTime, delay);
% Author: Daniel Mårtensson, November 2017
% Update January 2019 - Better hankel matrix that fix the 1 step delay.

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
  
  % Check if g can be diveded with 2
  if mod(length(g), 2) > 0
    error('The output cannot be divided with 2')
  end

  % Create hankel matrecies
  H0 = hank(g, 1);
  H1 = hank(g, 2);
  
  % Do SVD on H0
  [U,S,V] = svd(H0, 'econ');
  
  % Do model reduction
  [Un, En, Vn, nx] = modelReduction(U, S, V);
  
  % Create scalar for Bb, Cd
  ny = size(g, 1); % Number of outputs, we already know the number of inputs
  Ey = [eye(ny) zeros(ny,size(Un*En^(1/2),1) - size(eye(ny),1))]';
  Eu = [eye(nu) zeros(nu,size(En^(1/2)*Vn',2) - size(eye(nu),2))]';
  
  % Create matrix
  Ad = En^(-1/2)*Un'*H1*Vn*En^(-1/2);
  Bd = En^(1/2)*Vn'*Eu;
  Cd = Ey'*Un*En^(1/2);
  Dd = zeros(ny, nu);
  
  % Create state space model now
  sysd = ss(delay, Ad, Bd, Cd, Dd);
  sysd.sampleTime = sampleTime;
end

% Create the hankel matrix - For MIMO now
function [H] = hank(g, k)
  for i = 1:size(g, 1)
    A = hankel(g(i,:))(1:length(g(i,:))/2,1+k:length(g(i,:))/2+k);
    H(i, :) = reshape(A, 1, size(A, 1)*size(A, 2));
  end
  H = reshape(H, size(g, 1)*size(A, 1), size(A, 2));
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
