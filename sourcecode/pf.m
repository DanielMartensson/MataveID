% Particle Filter
% Input: x(state input, e.g measurement), xhatp(past estimated state input), k(counter), horizon(matrix), noise(matrix)
% Output: xhat(estimated state), horizon(matrix), k(counter), noise(matrix)
% Example 1: [xhat, horizon, k, noise] = pf(x, xhatp, k, horizon, noise);
% Author: Daniel Mårtensson, Oktober 23:e 2022

function [xhat, horizon, k, noise] = pf(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get state input
  if(length(varargin) >= 1)
    x = varargin{1};
  else
    error('Missing state input')
  end

  % Get past estimated state input
  if(length(varargin) >= 2)
    xhatp = varargin{2};
  else
    error('Missing past state input')
  end

  % Get horizon index
  if(length(varargin) >= 3)
    k = varargin{3};
  else
    error('Missing horizon index')
  end

  % Get horizon
  if(length(varargin) >= 4)
    horizon = varargin{4};
  else
    error('Missing horizon')
  end

  % Get noise matrix
  if(length(varargin) >= 5)
    noise = varargin{5};
  else
    error('Missing noise matrix')
  end

  % Get state dimension m
  m = size(x, 1);

  % Create the estimated state
  xhat = zeros(m, 1);

  % Get length of horizon matrix, which is the same length as noise matrix
  p = size(horizon, 2);

  % Horizon matrix shifting
  horizon = shift_matrix(horizon, x, p, k, m);

  % Compute the kernel density function from the horizon
  [P, H] = kernel_density_estimation(horizon, m, p, noise);

  % Create noise vector
  e = zeros(m, 1);

  % Estimate the next value
  for i = 1:m
    % Find the corresponding index of x and sorted H
    absolute_values = abs(x(i) - H(i, :));
    [~, index] = min(absolute_values);

    % Compute the ratio (0.5-1.0)
    % If P(i, index) = 1 (100%), then ratio = 0.5 (Good)
    % If P(i, index) = 0 (0%), then ratio = 1.0 (Problem, bad kernel density estimation...)
    ratio = x(i)/(x(i) + x(i) * P(i, index));

    % Difference between old and new
    diff = x(i) - xhatp(i);
    
    % This gives a smoother filtering
    horizon(i, k) = horizon(i, k)*abs(diff);
    
    % Update state. It MUST be negative
    xhat(i) = x(i) - ratio*diff;

    % Compute the noise
    e(i) = xhat(i) - x(i);
  end

  % Noise matrix shifting
  noise = shift_matrix(noise, e, p, k, m);

  % Next matrix column
  if(k < p)
    k = k + 1;
  end
end

function matrix = shift_matrix(matrix, x, p, k, m)
  % Matrix shifting
  for i = 1:m
    % Shift
    if(k >= p)
      % Shift the matrix with -1 step
      matrix(i, 1:p-1) = matrix(i, 2:p);
    end

    % Add the last
    matrix(i, k) = x(i);
  end
end

function [P, H] = kernel_density_estimation(x, m, n, noise)
  % Sort x so smallest values first because H is like a histogram with only one count for each value
  H = sort(x, 2, 'ascend');

  % Create empty array
  P = zeros(m, n);

  % Loop every row of P
  for i = 1:m
    % Get the whole row
    h = H(i, :);

    % Assume that the sigma is the standard deviation of the noise
    sigma = std(noise(i, :));

    % Loop every column of H
    for j = 1:n
      % Assume that the j:th value of h(j) is the mean
      mu = h(j);

      % Compute the propability of every values of h and add them to P
      P(i, :) = P(i, :) + normal_pdf(h, mu, sigma);
    end
  end

  % Turn P into a probability where the largest number is 1.0 (100%)
  for i = 1:m
    P(i, :) = P(i, :) / max(P(i, :));
  end
end

function y = normal_pdf(x, mu, sigma)
  % Normal distribution
  y = 1/(sigma*sqrt(2*pi))*e.^(-1/2*(x-mu).^2/sigma^2);
end
