% Minimize the least square cost function
% Input: X(input signal), Y(output signal),
% Output: K(Slope), y(Straight line formula)
% Example 1: [K, y] = lineq(Y, X);
% Author: Daniel Mårtensson, November 2017

function [K, y] = lineq(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
  end
  
  % Get the first vector
  if(length(varargin) > 0)
    output = varargin{1};
  else
    error('No output as input')
  end
  
  % Get the second vector
  if(length(varargin) > 1)
    input = varargin{2};
  else
    error('No input as input')
  end
  
  % Check if input have the same length as output
  if length(output) ~= length(input)
    error('Input must have the same length as output');
  end
  
  % Find K and M - Least square
  [m, n] = size(output);
  b = output(:); % b as a vector
  A = [input(:) ones(m, n)']; % ones() are for the M scalar
  
  % Ax = b formula
  x = A\b;
  % Get K and M now
  K = x(1); 
  M = x(2);
  
  y = sprintf('%ix + %i', K, M);
  % Plot
  plot(input, output, input, K.*input+M);
  title('Linear equation estimation');
  ylabel('Output');
  xlabel('Input');
  legend('Measured', 'Estimated');
end
