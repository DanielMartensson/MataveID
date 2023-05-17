% K-means clustering
% Input: X(data), k(amount of clusters)
% Output: idx(row index of class ID), C(coordinates of the centers of the cluster coordinates)
% Example 1: [idx, C] = mi.kmeans(X, k)
% Author: Daniel Mårtensson, April 2023

function [idx, C] = kmeans(X, k)
  % Get size of X
  [m, n] = size(X);

  % Find a random initial start
  C = X(randperm(m, k), :);

  % Iterate the solution
  max_iter = 100;
  old_value = 0;
  for i = 1:max_iter
      % Compute euclidean distance
      D = euclidean_distance(X, C);

      % Create points to nearest cluster
      [~, idx] = min(D, [], 2);

      % Update the center of the cluster coordinates
      for j = 1:k
          C(j,:) = mean(X(idx == j, :), 1);
      end

      % Check if we are going to break the iteration
      new_value = sum(C(:));
      difference = abs(old_value - new_value);
      if(difference < 0.001)
        i
        break;
      end
      old_value = new_value;
  end
end

function D = euclidean_distance(X, Y)
  Yt = Y';
  XX = sum(X.*X,2);
  YY = sum(Yt.*Yt,1);
  D = XX + YY - 2*X*Yt;
end
