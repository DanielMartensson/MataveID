% Estimate a transfer function of time doman data
% Example [sysd] = tfest(u, y, p, z, sampleTime, delay);
% Author: Daniel Mårtensson, November 2017

function [sysd] = tfest(varargin)
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
    error('Missing output');
  end
  
  % Get number of poles
  if(length(varargin) >= 3)
    np = varargin{3};
  else
    error('Missing number of poles');
  end
  
  % Get number of zeros
  if(length(varargin) >= 4)
    nz = varargin{4};
  else
    error('Missing number of zeros');
  end
  
  % Get the sample time
  if(length(varargin) >= 5)
    sampleTime = varargin{5};
  else
    error('Missing sample time');
  end
  
  % Get the delay
  if(length(varargin) >= 6)
    delay = varargin{6};
  else
    delay = 0; % If no delay was given
  end
  
  % Check if length of y is equal to length of u
  if length(u) ~= length(y)
    error('Input and output has not equal length')
  end

  % check which one is largest
  kn = length(u); % or length(y)
  
  % Create b vector - all the y[k]
  b = y(1:kn)';
  
  % Create A1 matrix
  A1 = zeros(kn, np);
  
  % Fill A1 matrix - The y values
  for i = 1:kn
    for j = 1:np 
      
      if i-j <= 0
        A1(i,j) = 0;
      else
        A1(i,j) = -y(i-j);
      end
      
    end
  end
  
  % Create A2 matrix
  A2 = zeros(kn, nz);
  
  % Fill A2 matrix - The u values
  for i = 1:kn
    for j = 1:nz
      
      if i-j <= 0
        A2(i,j) = 0;
      else
        A2(i,j) = u(i-j);
      end
      
    end
  end
  
  % Merge A1 and A2 into A
  A = [A1 A2];
  
  % Solve x by linear solve
  x = linsolve(A, b)';
  
  % Get the denominator and numerator. The 1 is the scalar of y[k]
  den = [1 (x(1, 1:np))];
  num = (x(1, (np+1):end));
  
  % Create the discrete transfer function with delay or no delay
  if delay > 0
    Gd = tf(num, den, delay);
  else
    Gd = tf(num, den);
  end
  
  % Change the sampleTime
  Gd.sampleTime = sampleTime;
  
  % Replace the delaytime to discrete delay time
  Gd.tfdash = strrep(Gd.tfdash, 'e', 'z');
  Gd.tfdash = strrep(Gd.tfdash, 's', '');
  % Remove all s -> s
  Gd.tfnum = strrep(Gd.tfnum, 's', 'z');
  Gd.tfden = strrep(Gd.tfden, 's', 'z');
  
  % Convert the Gd into a state space model
  sysd = tf2ss(Gd, 'OCF');

end