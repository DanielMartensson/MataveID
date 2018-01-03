% Arbitrary Subspace Algorithm 
% Input: u, y, h, delay(optional)
% Example [sysd] = asa(u, y, h, delay);
% Author: Daniel Mårtensson, December 2017

function [sysd] = asa(varargin)
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
  
  % Check if y can be diveded with 2
  if mod(length(y), 2) > 0
    error('The output cannot be divided with 2')
  end
  
  % Get number of inputs (m) and outputs (l) and dimension i
  m = size(u, 1);
  l = size(y, 1);
   
  % Get hankel matrices
  H1 = hank([u;y], 1);
  H2 = hank([u;y], 2);
  
  % Do SVD on H
  [U,S,V] = svd([H1;H2], 'econ');
  
  % Do model reduction
  [U11, U12, U21, U22, S11, n] = modelReduction(U, S, V); 
  
  % Compute another SVD
  [Uq,Sq,Vq] = svd(U12'*U11*S11, 'econ');
  
  % Find the states and input/outputs vectors
  i = n/(l+m); % Important! Or else the algorithm won't work - My own modification :)
  dxk = Uq'*U12'*U((m + l + 1 ):( i + 1 )*( m + l ), :)*S;
  yk  = U((m*i + l*i + m + 1):(m + l)*(i + 1), :)*S;
  xk  = Uq'*U12'*U(1:(m*i + l*i ), :)*S;
  uk  = U((m*i + l*i + 1):(m*i + l*i + m), :)*S;

  % Solve matrices by using least square
  ABCD = [dxk; yk]/[xk; uk];

  % Extract the system matrices
  Ad = ABCD(1:n, 1:n);
  Bd = ABCD(1:n, (n + 1):(n + m));
  Cd = ABCD((n + 1):(n + l), 1:n);
  Dd = ABCD((n + 1):(n + l), (n + 1):(n + m));
  
  % Create the state space model
  sysd = ss(delay, Ad, Bd, Cd, Dd);
  sysd.sampleTime = sampleTime;
end


function [U11, U12, U21, U22, S11, n] = modelReduction(U, S, V)
  % Plot singular values 
  stem(diag(S));
  title('Hankel Singular values');
  xlabel('Amount of singular values');
  ylabel('Value');
  
  % Choose system dimension n - Remember that you can use modred.m to reduce some states too!
  n = inputdlg('Choose the state dimension by looking at hankel singular values: ');
  n = str2num(cell2mat(n));
  
  % Find the size
  [um, un] = size(U);
  [sm, sn] = size(S);
   % Check if un and sn can be divided with 2
  if mod(un, 2) > 0
    error('Need to incresse number of measurements')
  end
  if mod(sn, 2) > 0
    error('Need to incresse number of measurements')
  end
  
  
  % Split them up
  U11 = U(1:um/2, 1:un/2);
  U12 = U(1:um/2, (1 + un/2):un);
  U21 = U((1 + um/2):um, 1:un/2);
  U22 = U((1 + um/2):um, (1 + un/2):un);
  S11 = S(1:sm/2, 1:sn/2);

  % Do reduction - No need to do reduction for Uq later
  U11 = U11(1:n, 1:n);
  U12 = U12(1:n, 1:n);
  U21 = U21(1:n, 1:n);
  U22 = U22(1:n, 1:n);
  S11 = S11(1:n, 1:n);
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