% Kernel Principal Component Analysis
% Input: X(Data), c(Amount of components), kernel_type, kernel_parameters
% Output: Projected matrix P, Project matrix W
% Example 1: [P, W] = mi.kpca(X, c);
% Example 2: [P, W] = mi.kpca(X, c, kernel_type);
% Example 3: [P, W] = mi.kpca(X, c, kernel_type, kernel_parameters);
% Author: Daniel Mårtensson, 2023 Juli

function [P, W, mu] = kpca(varargin)
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

  % Create kernel
  disp('Creating kernel');
  K = create_kernel(X, kernel_type, kernel_parameters);
  disp('Done');

  % Do PCA
  disp('Createing PCA of the kernel')
  [~, W] = mi.pca(K, c);

  % We projecting X onto W' instead of K onto W'
  P = W'*X;
  disp('Done');
end

function K = create_kernel(X, kernel_type, kernel_parameters)
  % Select kernel type
  switch kernel_type
    case 'gaussian'
    % Compute the euclidean distanses
    D = sqrt(distEucSq(X, X));
    sigma = kernel_parameters(1);
    K = exp(-D.^2 / (2 * sigma^2));

    case 'exponential'
    % Compute the euclidean distanses
    D = sqrt(distEucSq(X, X));
    sigma = kernel_parameters(1);
    K = exp(-D / (2 * sigma^2));

    case 'polynomial'
    degree = kernel_parameters(1);
    K = (X*X').^degree;

    case 'linear'
    K = X * X';

    case 'sigmoid'
    alpha = kernel_parameters(1);
    beta = kernel_parameters(2);
    K = tanh(alpha * X * X' + beta);

    case 'rbf'
    % Compute the euclidean distanses
    D = sqrt(distEucSq(X, X));
    gamma = kernel_parameters(1);
    K = exp(-gamma*D.^2);

    otherwise
      error('Kernel type does not exist!');
    end
end

function D = distEucSq(X, Y)
  Yt = Y';
  XX = sum(X.*X,2);
  YY = sum(Yt.*Yt,1);
  D = abs(bsxfun(@plus,XX,YY)-2*X*Yt);
end
