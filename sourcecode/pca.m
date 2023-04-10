% Principal Component Analysis
% Input: X(Data), c(Amount of components)
% Output: Projected matrix P, Project matrix W
% Example 1: [P, W] = pca(X, c);
% Author: Daniel Mårtensson, 2023 April

function [P, W] = pca(varargin)
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

  % Average
  mu = mean(X);

  % Center data
	Y = X - mu;

  % Create the covariance
  Z = cov(Y);

  % PCA analysis
	[~, ~, V] = svd(Z, 0);

  % Projection
	W = V(:, 1:c);
	P = X*W;
end
