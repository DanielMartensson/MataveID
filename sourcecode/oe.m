% Output Error estimation model
% Input: u(input signal), y(output signal), e(noise), np(number of poles), nz(number of zeros), sampleTime, delay(optional) 
% Output: sysd(Discrete state space model with noise), Gd(Discrete transfer function)
% Example 1: [sysd] = oe(u, y, e, np, nz, sampleTime, delay);
% Example 2: [sysd, Gd] = oe(u, y, e, np, nz, sampleTime);
% Author: Daniel Mårtensson, November 2017

function [sysd, Gd] = oe(varargin)
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
  
  % Get noise
  if(length(varargin) >= 3)
    e = varargin{3};
  else
    error('Missing noise');
  end
  
  % Get number of poles
  if(length(varargin) >= 4)
    np = varargin{4};
  else
    error('Missing number of poles');
  end
  
  % Get number of zeros
  if(length(varargin) >= 5)
    nz = varargin{5};
  else
    error('Missing number of zeros');
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
  
  % Create A3 matrix - Noise
  A3 = zeros(kn, np);
  
  % Fill A1 matrix - The y values
  for i = 1:kn
    for j = 1:np 
      
      if i-j <= 0
        A3(i,j) = 0;
      else
        A3(i,j) = e(i-j);
      end
      
    end
  end
  
  % Merge A1 and A2 and A3 into A
  A = [A1 A2 A3];
  
  % Solve x by linear solve
  x = linsolve(A, b)';
  
  % Get the denominator and numerator. The 1 is the scalar of y[k]
  den = [1 (x(1, 1:np))];
  num = (x(1, (np+1):(np + nz)));
  
  % Create the discrete transfer function with delay or no delay
  if delay > 0
    Gd = tf(num, den, delay);
  else
    Gd = tf(num, den);
  end
  
  % Change the sampleTime
  Gd.sampleTime = sampleTime;
  
  if delay > 0
    Hd = tf(1, 1, delay);
  else
    Hd = tf(1, 1);
  end
  
  Hd.sampleTime = sampleTime;
  
  sysg = tf2ss(Gd, 'CCF');
  sysh = tf2ss(Hd, 'CCF');
  
  sysd = append(sysg, sysh);
  
  % Change C matrix so noise effect both output
  sysd.C = sysd.C(1,:);
  sysd.C(1, end) = 1;
  % Change D matrix too
  sysd.D = [0 0]; 
  
  % Now convert this into state space
  %sysd = tf2ss(Gd, 'CCF');
  
  % Change B and D matrix - MISO - Mutiple input and single output
  %sysd.B = [sysd.B zeros(size(sysd.B))];
  %sysd.D = [0 1]; % The scalar of e(t)
  

end