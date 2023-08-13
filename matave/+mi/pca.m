% Principal Component Analysis
% Input: X(Data), c(Amount of components)
% Output: Projected matrix P, Project matrix W, mu(Average vector of X)
% Example 1: [P, W] = mi.pca(X, c);
% Example 2: [P, W, mu] = mi.pca(X, c);
% Author: Daniel Mårtensson, 2023 April

function [P, W, mu] = pca(varargin)
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

  % PCA analysis
  abort = input(sprintf('The size of the matrix is %ix%i. Do you want to apply PCA onto it? 1 = Yes, 0 = No: ', size(Y)));
  if(abort == 1)
    [U, ~, ~] = svdecon(Y);
  else
    error('Aborted');
  end

  % Projection
  W = U(:, 1:c);
  P = W'*Y;
end

function [U,S,V] = svdecon(X)
  % Input:
  % X : m x n matrix
  %
  % Output:
  % X = U*S*V'
  %
  % Description:
  % Does equivalent to svd(X,'econ') but faster
  %
  % Vipin Vijayan (2014)
  %X = bsxfun(@minus,X,mean(X,2));
  [m,n] = size(X);
  if  m <= n
      C = X*X';
      [U,D] = eig(C);
      clear C;

      [d,ix] = sort(abs(diag(D)),'descend');
      U = U(:,ix);

      if nargout > 2
          V = X'*U;
          s = sqrt(d);
          V = bsxfun(@(x,c)x./c, V, s');
          S = diag(s);
      end
  else
      C = X'*X;
      [V,D] = eig(C);
      clear C;

      [d,ix] = sort(abs(diag(D)),'descend');
      V = V(:,ix);

      U = X*V; % convert evecs from X'*X to X*X'. the evals are the same.
      %s = sqrt(sum(U.^2,1))';
      s = sqrt(d);
      U = bsxfun(@(x,c)x./c, U, s');
      S = diag(s);
  end
end
