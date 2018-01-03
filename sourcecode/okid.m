% Observer Kalman-Filter IDentification
% Input: u, y, h, delay(optional)
% Example [sysd] = okid(u, y, h, delay);
% Author: Daniel Mårtensson, December 2017

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
  

  % Get the dimension of y and u
  [q, p] = size(y);
  [m, lu] = size(u);

  % Get the markov parameters Ybar
  V = zeros(m + (m+q)*p,p);
  for i = 1:p
      V(1:m,i) = u(1:m,i);
  end
  
  for i = 2:p+1
      for j = 1:p+1-i
          temporaryV = [u(:,j);y(:,j)];
          V(m+(i-2)*(m+q)+1:m+(i-1)*(m+q),i+j-1) = temporaryV;
      end
  end

  % Use pseudo inverse  
  Ybar = y*pinv(V, 1e-5);
  
  % Get the first markov parameter
  YbarD = Ybar(:, 1:m);  
  
  % Use the rest of the markov parameter - Get rid of D 
  Ybar = Ybar(:, m+1:end);

  % Create Ybar1 and Ybar2 to fill upp with
  Ybar1 = zeros(q, m, length(Ybar));
  Ybar2 = zeros(q, q, length(Ybar));
  
  % Fill upp Ybar1 and Ybar2 with raw markov parameters
  for i= 1:p
      Ybar1(:, :, i) = Ybar(:, 1+(m+q)*(i-1):(m+q)*(i-1)+m);
      Ybar2(:, :, i) = Ybar(:, (m+q)*(i-1)+m+1:(m+q)*(i-1)+m+q);
  end

  % Now create the almost last part of the markow parameters
  Y(:, :, 1) = Ybar1(:, :, 1) + Ybar2(:, :, 1)*YbarD;
  
  % Use the summation just as in the formulas described inside the OKID report.
  for k= 2:p
      Y(:, :, k) = Ybar1(:, :, k) + Ybar2(:, :, k)*YbarD;
      for i= 1:k-1
          Y(:, :, k) = Y(:, :, k) + Ybar2(:, :, i)*Y(:, :, k-i);
      end
  end

  
  % Now - Create all markov parameters for estimation
  H = YbarD;
  for k= 1:p
      H = [H Y(:, :, k)];
  end
  
  
  % Use ERA algorithm
  H0 = hank(H, 1);
  H1 = hank(H, 2);

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
  nu = 1; % This model can only have on input
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