% Kernel Principal Component Analysis
% Input: X(Data), c(Amount of components), kernel_type, kernel_parameters
% Output: Kernel Matrix K, Projected matrix P, Project matrix W, mu(Average vector of X)
% Example 1: [K, P, W, mu] = mi.kpca(X, c);
% Example 2: [K, P, W, mu] = mi.kpca(X, c, kernel_type);
% Example 3: [K, P, W, mu] = mi.kpca(X, c, kernel_type, kernel_parameters);
% Author: Daniel Mårtensson, 2023 Juli

function [K, P, W, mu] = kpca(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get impulse response
  if(length(varargin) >= 1)
    X = varargin{1};
  else
    error('Missing data X')
  end

  % Get the amount of components
  if(length(varargin) >= 2)
    c = varargin{2};
  else
    error('Missing amount of components');
  end

  % Get the kernel type
  if(length(varargin) >= 3)
    kernel_type = varargin{3};
  else
    kernel_type = 'linear';
  end

   % Get the kernel parameters
  if(length(varargin) >= 4)
    kernel_parameters = varargin{4};
  else
    if(strcmp(kernel_type, 'linear'))
      kernel_parameters = zeros(1,1);
    else
      error('Missing kernel parameters');
    end
  end

  % Create kernel of X
  K = create_kernel(X, kernel_type, kernel_parameters);

  % Do PCA
  [P, W, mu] = mi.pca(K, c);
end

function K = create_kernel(X, kernel_type, kernel_parameters)
  % Get the rows of X
  m = size(X, 1);

  % Create empty kernel
  K = zeros(m, m);

  % Select kernel type
  switch kernel_type
    case 'gaussian'
    sigma = kernel_parameters(1);
    for i = 1:m
        for j = 1:m
            K(i, j) = exp(-norm(X(i, :) - X(j, :))^2 / (2 * sigma^2));
        end
    end

    case 'exponential'
    sigma = kernel_parameters(1);
    for i = 1:m
        for j = 1:m
             K(i, j) = exp(-norm(X(i, :) - X(j, :)) / (2 * sigma^2));
        end
    end

    case 'polynomial'
    degree = kernel_parameters(1);
    for i = 1:m
        for j = 1:m
            K(i, j) = (dot(X(i, :), X(j, :)) + 1)^degree;
        end
    end

    case 'linear'
    K = X * X';

    case 'sigmoid'
    alpha = kernel_parameters(1);
    beta = kernel_parameters(2);
    K = tanh(alpha * X' * X + beta);

    case 'rbf'
    gamma = kernel_parameters(1);
    for i = 1:m
        for j = 1:m
            K(i, j) = exp(-gamma * norm(X(i, :) - X(j, :))^2);
        end
    end

    otherwise
      error('Kernel type does not exist! Try with sigmoid, linear, polynomial, exponential, gaussian');
    end
end
