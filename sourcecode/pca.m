% Principal Component Analysis
% Input: X(Data), c(Amount of components), cluster_limit
% Output: Projected matrix P, Project matrix W
% Example 1: [P, W] = pca(X, c, cluster_limit);
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

  % Get the cluster limit
  if(length(varargin) >= 3)
    cluster_limit = varargin{3};
  else
    error('Missing cluster limit');
  end

  % Average
  mu = mean(X);

  % Center data
	Y = X - mu;

  % Filter the data
  Y = cluster_filter(Y, cluster_limit);

  % Create the covariance
  Z = cov(Y);

  % PCA analysis
	[~, ~, V] = svd(Z, 0);

  % Projection
	W = V(:, 1:c);
	P = X*W;
end

function X = cluster_filter(X, cluster_limit)
  % Get size of X
  [m, n] = size(X);

  % Create these arrays
  nearest_distance = zeros(1, m);
  nearest_row = zeros(1, m);
  computed_row = zeros(1, m);

  % Start counting the euclidean distance
  selected_row = 1;
  chosen_row = 1;
  for i = 1:m
    % Compare for smallest distance
    minimal_distance = 0;
    first_iteration = true;
    for compare_row = 1:m
      if(and(selected_row ~= compare_row, ~computed_row(compare_row)))
        % Do L2-norm
        a = X(selected_row, :);
        b = X(compare_row, :);
        c = norm(a - b, 2);
        if(or(c < minimal_distance, first_iteration == true))
          minimal_distance = c;
          chosen_row = compare_row;
          first_iteration = false;
        end
      end
    end

    % Now we have the minimal distance between selected_row and chosen_row
    nearest_distance(i) = minimal_distance;
    nearest_row(i) = selected_row;
    computed_row(selected_row) = true;

    % Next selected row
    selected_row = chosen_row;
  end

  % The last distance index is always zero due to computed_row array.
  % Give the last distance the same value ans the second last distance
  nearest_distance(end) = nearest_distance(end - 1);

  % Compute the average of nearest distances
  average_distance = mean(nearest_distance);

  % Delete rows that are far away
  cluster_points = 0;
  for i = 1:m
    if(nearest_distance(i) < average_distance)
      cluster_points = cluster_points + 1;
    else
      if(and(cluster_points < cluster_limit, cluster_points > 0))
        % Delete by centering the data in X
        for j = i - cluster_points + 1 : i
          % All rows from i:th back to i - cluster_points will be deleted
          X(nearest_row(j), :) = 0;
        end
      else
        % Delete a single spot because it's violating the distance
        X(nearest_row(i), :) = 0;
      end
      cluster_points = 0;
    end
  end
end
