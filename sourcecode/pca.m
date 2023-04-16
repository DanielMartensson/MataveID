% Principal Component Analysis with cluster filtering
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

  % Filter the data
  X = cluster_filter(X);

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

function X = cluster_filter(X)
  % Get size of X
  [m, n] = size(X);

  % Create these arrays
  nearest_distance = zeros(1, m);
  already_computed_row = zeros(1, m);

  % Start counting the euclidean distance
  selected_row = 1;
  chosen_row = 1;
  for i = 1:m
    % Compare for smallest distance
    minimal_distance = 0;
    first_iteration = true;
    for compare_row = 1:m
      if(and(selected_row ~= compare_row, or(~already_computed_row(compare_row), i == m)))
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
    nearest_distance(selected_row) = minimal_distance;
    already_computed_row(selected_row) = true;

    % Next selected row
    selected_row = chosen_row;
  end

  % Compute the average of nearest distances
  average_distance = mean(nearest_distance);

  % Compute the cluster limit
  cluster_points = 0;
  counted_clusters = 0;
  total_cluster_points = 0;
  for i = 1:m
    % Check if it changes
    if(nearest_distance(i) < average_distance)
      cluster_points = cluster_points + 1;
    else
      if(cluster_points > 0)
        counted_clusters = counted_clusters + 1;
        total_cluster_points = total_cluster_points + cluster_points;
      end
      cluster_points = 0;
    end
  end
  cluster_limit = 0;
  if(counted_clusters > 0)
    cluster_limit = total_cluster_points / counted_clusters;
  end

  % Notice which rows has outliers
  cluster_points = 0;
  outliers_row_index = zeros(1, m);
  counter_outliers = 0;
  for i = 1:m
    if(nearest_distance(i) < average_distance)
      cluster_points = cluster_points + 1;
    else
      if(and(cluster_points < cluster_limit, cluster_points > 0))
        for j = i - cluster_points : i
          % Count multiple outliers
          outliers_row_index(counter_outliers + 1) = j;
          counter_outliers = counter_outliers + 1;
        end
      else
        % Count a single outlier
        outliers_row_index(counter_outliers + 1) = i;
        counter_outliers = counter_outliers + 1;
      end
      cluster_points = 0;
    end
  end

  % If we got some outliers
  if(counter_outliers > 0)
    % Find a non outlier row index
    non_outlier_row_index = 1;
    for i = 1:m
      % Flag
      is_outlier_row_index = false;

      % Loop through
      for j = 1:counter_outliers
        if(i == outliers_row_index(j))
          is_outlier_row_index = true;
          break;
        else
          non_outlier_row_index = i;
        end
      end

      % Break when an outlier is not found = we found an index of an non outliner
      if(~is_outlier_row_index)
        break;
      end
    end

    % Delete them by replacing outliers with non outliers
    for j = 1:counter_outliers
      X(outliers_row_index(j), :) = X(non_outlier_row_index, :);
    end
  end
end
