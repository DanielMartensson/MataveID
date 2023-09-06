% Robust Principal Component Analysis
% Input: data matrix(X)
% Output: L(filtred data matrix), S(sparse noise matrix)
% Example 1: [L, S] = mi.rpca(X)
% Author: Daniel Mårtensson, 28 April 2021

function [L, S] = rpca(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing input')
  end
  
  % Get X
  X = varargin{1};
  
  % Get size of the matrix X
  [n1, n2] = size(X);
  
  % Get two tuning factors
  mu = n1*n2/(4*sum(abs(X(:))));
  lambda = 1/sqrt(max(n1, n2));
  
  % Create a threshold 
  thresh = 1e-6*norm(X, 'fro');
  
  % Create three matrices 
  L = zeros(size(X));
  S = zeros(size(X));
  Y = zeros(size(X));
  
  % Start optimization
  count = 0;
  while(and(norm(X-L-S, 'fro') > thresh, count < 1000))
    L = SVT(X-S+(1/mu)*Y, 1/mu);
    S = shrink(X-L+(1/mu)*Y, lambda/mu);
    Y = Y + mu*(X-L-S);
    count = count + 1;
  end
end

function out = SVT(X, tau)
  [U, E, V] = svd(X, 'econ');
  out = U*shrink(E, tau)*V';
end

function out = shrink(X, tau)
  out = sign(X).*max(abs(X) - tau, 0);
end
