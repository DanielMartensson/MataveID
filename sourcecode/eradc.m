% Eigensystem Realization Algorithm Data Correlation
% Input: g(markov parameters), nu(number of inputs), sampleTime, delay(optional)
% Output: sysd(Discrete state space model)
% Example 1: [sysd] = eradc(g, nu, sampleTime, delay);
% Author: Daniel Mårtensson, November 2017

function [sysd] = eradc(varargin)
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
  
  % Get the sample time
  if(length(varargin) >= 2)
    sampleTime = varargin{2};
  else
    error('Missing sample time');
  end
  
  % Get the number of input
  if(length(varargin) >= 3)
    nu = varargin{3};
  else
    error('Missing number of input');
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

  % Create hankel matrices 
  H0 = hank(g, 1);
  H1 = hank(g, 2);
  H2 = hank(g, 3);
  H3 = hank(g, 4);
  H4 = hank(g, 5);
  H5 = hank(g, 6);
  H6 = hank(g, 7);
  H7 = hank(g, 8);
  H8 = hank(g, 9);
  H9 = hank(g, 10);
  
  % To add data correlation, we need to do this:
  HH0 = H0*H0';
  HH1 = H1*H0';
  HH2 = H2*H0';
  HH3 = H3*H0';
  HH4 = H4*H0';
  HH5 = H5*H0';
  HH6 = H6*H0';
  HH7 = H7*H0';
  HH8 = H8*H0';
  HH9 = H9*H0';
  
  % Two big hankel matrices
  HHH0 = [HH0 HH1 HH2 HH3 HH4; 
          HH1 HH2 HH3 HH4 HH5;
          HH2 HH3 HH4 HH5 HH6;
          HH3 HH4 HH5 HH6 HH7;
          HH4 HH5 HH6 HH7 HH8];
  
  HHH1 = [HH1 HH2 HH3 HH4 HH5; 
          HH2 HH3 HH4 HH5 HH6;
          HH3 HH4 HH5 HH6 HH7;
          HH4 HH5 HH6 HH7 HH8;
          HH5 HH6 HH7 HH8 HH9];
  
  
  
  % Do SVD on HH0
  [U,S,V] = svd(HHH0, 'econ');
  
  % Do model reduction
  [Un, En, Vn, nx] = modelReduction(U, S, V);
  
  % Create scalar for Bb, Cd
  ny = size(g, 1); % Number of outputs, we already know the number of inputs
  gamma = size(H0, 1); % Get the row size of H0 - This one is special case for ERA/DC
  Er = [eye(gamma) zeros(gamma,size(En^(1/2)*Vn',2) - size(eye(gamma),2))]';
  Ey = [eye(ny) zeros(ny,size(Un*En^(1/2),1) - size(eye(ny),1))]';
  Eu = [eye(nu) zeros(nu,size(pinv(Er'*Un*En^(1/2))*H0,2) - size(eye(nu),2))]';
  
  % Create matrix - Notice the change
  Ad = En^(-1/2)*Un'*HHH1*Vn*En^(-1/2);
  Bd = pinv(Er'*Un*En^(1/2))*H0*Eu;
  Cd = Ey'*Un*En^(1/2);
  Dd = zeros(ny, nu);

  % Create state space model now
  sysd = ss(delay, Ad, Bd, Cd, Dd);
  sysd.sampleTime = sampleTime;
end

function [H] = hank(g, k)
  % Create hankel matrix
  H = cell(length(g)/2 - 4, length(g)/2 - 4); 
  
  for i = 1:(length(g)/2 - 4)
    for j = 1:(length(g)/2 - 4)
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