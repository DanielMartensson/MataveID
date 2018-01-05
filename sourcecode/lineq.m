% Minimize the least square cost function
% Input: X(input signal), Y(output signal),
% Output: K(Slope), y(Straight line formula)
% Example 1: [K, y] = lineq(Y, X);
% Author: Daniel Mårtensson, November 2017

function [K, f] = lineq(varargin)
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
  
  % Find K
  K = sum(output.*input)./sum(input.^2);
  y = sprintf('%ix + %i', K, output(end)-K*input(end));
  % Plot
  plot(input, output, input, K.*input);
  title('Linear equation estimation');
  ylabel('Output');
  xlabel('Input');
  legend('Measured', 'Estimated');
end
