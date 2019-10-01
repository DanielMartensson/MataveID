% Recursive Least Square
% Input: u(input signal), y(output signal), np(number of poles), nz(number of zeros), nze(number of zeros for Hd), sampleTime, delay(optional), forgetting(optional) 
% Output: Gd(Discrete transfer function), Hd(Discrete transfer function for noise), sysd(Discrete state space model with noise), K(Kalman filter)
% Example 1: [Gd, Hd] = rls(u, y, e, np, nz, nze, sampleTime);
% Example 2: [Gd, Hd, sysd, K] = arx(u, y, e, np, nz, nze, sampleTime, delay, forgetting);
% Author: Daniel Mårtensson, September 2019

function [Gd, Hd, sysd, K] = rls(varargin)
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
    if(nz > np)
      error('nz > np');
    end
  else
    error('Missing number of zeros');
  end
  
  % Get number of zeros for Hd
  if(length(varargin) >= 5)
    nze = varargin{5};
    if(nze > np)
      error('nze > np');
    end
  else
    error('Missing number of zeros for Hd');
  end
  
  % Get the sample time
  if(length(varargin) >= 6)
    sampleTime = varargin{6};
    if(sampleTime <= 0)
      error('sampleTime <= 0');
    end
  else
    error('Missing sample time');
  end
  
  % Get the delay
  if(length(varargin) >= 7)
    delay = varargin{7};
    if(delay < 0)
      error('delay < 0');
    end
  else
    delay = 0; % If no delay was given
  end
  
  % Get the lambda factor
  if(length(varargin) >= 8)
    l = varargin{8};
    if(l <= 0)
      error('forgetting <= 0');
    end
  else
    l = 1; % If no lambda forgetting factor was given
  end
  
  % Initials
  Theta = [zeros(1, np) zeros(1, nz) zeros(1, nze)]';
  phi = [zeros(1, np) zeros(1, nz) zeros(1, nze)]';
  error = 0;
  
  % Initial P  
  c = 1000; % A large number
  I = eye(length(Theta));
  P = c*I;

  % Estimation loop - I made it this way so it would be easy to convert all to C code if needed
  for k = 1:length(u);
    
    if(k == 1)
      % Nothing here - Leave phi with only zeros - Important to have phi as zeros
    elseif(k == 2)
     
       % Insert the first values
       phi(1) = -y(k-1);
       phi(1+np) = u(k-1);
       phi(1+np+nz) = error;
              
    else

       % Shift 1 step for y
       for i = np-1:-1:1
         phi(i+1) = phi(i);
       end
       % Shift 1 step for u
       for i = nz-1:-1:1
         phi(i+np+1) = phi(i+np);
       end
       % Shift 1 step for e
       for i = nze-1:-1:1
         phi(i+np+nz+1) = phi(i+np+nz);
       end
       
       % Insert the values
       phi(1) = -y(k-1);
       phi(1+np) = u(k-1);
       phi(1+np+nz) = error;
       
    end

    % Call the recursive function - If need as C code, use call by reference
    [error, P, Theta] = recursive(y(k), phi, Theta, P, l);
       
  end
  
  % Create the discrete transfer function
  Gd = tf([Theta(np+1:np+nz)'],[1 Theta(1:np)']);
  Gd.sampleTime = sampleTime;
  
  % Replace the delaytime to discrete delay time
  Gd.tfdash = strrep(Gd.tfdash, 'e', 'z');
  Gd.tfdash = strrep(Gd.tfdash, 's', '');
  % Remove all s -> z
  Gd.tfnum = strrep(Gd.tfnum, 's', 'z');
  Gd.tfden = strrep(Gd.tfden, 's', 'z');
  
  % Create the discrete disturbance transfer function
  Hd = tf([Theta(nz+np+1:np+nz+nze)'],[1 Theta(1:np)']);
  Hd.sampleTime = sampleTime;
  
  % Replace the delaytime to discrete delay time
  Hd.tfdash = strrep(Hd.tfdash, 'e', 'z');
  Hd.tfdash = strrep(Hd.tfdash, 's', '');
  % Remove all s -> z
  Hd.tfnum = strrep(Hd.tfnum, 's', 'z');
  Hd.tfden = strrep(Hd.tfden, 's', 'z');
  
  % Create the SS model
  sysd = tf2ss(Gd, 'OCF');
  if(np == nze)
    K = (Theta(nz+np+1:np+nz+np)' - Theta(1:np)')'; % Kalman filter - Page 166 Adaptive Control Karl Johan Åström Second edition
    sysd.B = [sysd.B K];
    sysd.D = [0 1]; 
  else
    disp('No kalman filter estimation due to np =/= nze')
    K = 0;  
  end
  
end

% This follows the recursive least squares from Adaptive Control by Karl Johan Åström
function [error, P, Theta] = recursive(y, phi, Theta, P, l)
  % Error
  error = y - phi'*Theta;
    
  % Update P
  P = 1/l*(P - P*phi*phi'*P/(l + phi'*P*phi));
    
  % Update theta
  Theta = Theta + P*phi*error;
end
