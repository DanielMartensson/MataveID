% Density-based spatial clustering of applications with noise
% Input: X(data), epsilon(Radius), min_pts(Minimum points)
% Output: idx(row index of class ID)
% Example 1: [idx] = mi.dbscan(X, espsilon, min_pts)
% Author: Daniel Mårtensson, Juli 2023

function [idx] = dbscan(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get input
  if(length(varargin) >= 1)
    X = varargin{1};
  else
    error('Missing data X')
  end

  % Get radius epsilon
  if(length(varargin) >= 2)
    epsilon = varargin{2};
  else
    error('Missing radius epsilon')
  end

  % Get minimum points
  if(length(varargin) >= 3)
    min_pts = varargin{3};
  else
    error('Missing minimum points')
  end

  A = 0;
  n = size(X,1);
  idx = zeros(n,1);
  D = sqrt(distEucSq(X, X));
  visited = false(n, 1);
  for i=1:n
    if ~visited(i)
      visited(i) = true;
      neighbors1 = find(epsilon >= D(i,:));
      n1 = numel(neighbors1);
      if n1 > min_pts
        A = A + 1;
        idx(i) = A;
        k = 1;
        while true
          j = neighbors1(k);
          if ~visited(j)
            visited(j) = true;
            neighbors2 = find(epsilon >= D(j,:));
            n2 = numel(neighbors2);
            if n2 >= min_pts
              neighbors1 = [neighbors1 neighbors2];
            end
          end
          if idx(j) == 0
            idx(j) = A;
          end
          k = k + 1;
          if k > numel(neighbors1)
            break;
          end
        end
      end
    end
  end
end

function D = distEucSq(X, Y)
  Yt = Y';
  XX = sum(X.*X,2);
  YY = sum(Yt.*Yt,1);
  D = XX + YY - 2*X*Yt;
end
