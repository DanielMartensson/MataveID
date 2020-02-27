% Observer Kalman-Filter IDentification
% Input: u(input signal), y(output signal), sampleTime, delay(optional)
% Output: sysd(Discrete state space model)
% Example 1: [sysd] = okid(u, y, sampleTime, delay);
% Example 2: [sysd] = okid(u, y, sampleTime);
% Author: Daniel Mårtensson, December 2017
% Update January 2019 - Better hankel matrix that fix the 1 step delay.

function [sysd] = okid(varargin)
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
  
  % Check if u and y has the same length
  if(length(u) ~= length(y))
    error('Input(u) and output(y) has not the same length')
  end

  % Check how many dimensions u is
  for i = 1:size(u, 1)
    % Find impulse response
    g(i, :) = y(i,:)*pinv(triu(toeplitz(u(i,:))));
  end
  
  % Half hankel
  H0 = hank(g, 1);
  H1 = hank(g, 2);

  % Do SVD on H
  [U,E,V] = svd(H0, 'econ');
  
  % Plot singular values 
  stem(1:length(E), diag(E));
  title('Hankel Singular values');
  xlabel('Amount of singular values');
  ylabel('Value');
  
  % Choose system dimension n - Remember that you can use modred.m to reduce some states too!
  nx = inputdlg('Choose the state dimension by looking at hankel singular values: ');
  nx = str2num(cell2mat(nx));
 
  % Choose the dimension nx
  Un = U(:, 1:nx);
  En = E(1:nx, 1:nx);
  Vn = V(:, 1:nx);

  % Create scalar for Bb, Cd
  ny = size(y, 1); % Number of outputs
  nu = size(u, 1); % Size of input
  Ey = [eye(ny) zeros(ny,size(Un*En^(1/2),1) - size(eye(ny),1))]';
  Eu = [eye(nu) zeros(nu,size(En^(1/2)*Vn',2) - size(eye(nu),2))]';
  
  % Create matrix
  Ad = En^(-1/2)*Un'*H1*Vn*En^(-1/2);
  Bd = En^(1/2)*Vn'*Eu;
  Cd = Ey'*Un*En^(1/2);
  
  % Create state space model now - SIMO
  sysd = ss(delay, Ad, Bd, Cd); % Dn will be 0
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
