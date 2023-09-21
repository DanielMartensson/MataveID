% Hough transform - Line detection algorthm by using hough transform and DBscan
% Input: X(Data matrix of an edge image), p(Line length threshold in precent), epsilon(Minimum radius for hough cluster), min_pts(Minimum points for hough cluster)
% Output: N(Number of lines), K(Slopes for the lines), M(Bias for the lines)
% Example 1: [N, K, M] = mi.hough(X, p, epsilon, min_pts);
% Author: Daniel Mårtensson, 14 September 2023

function [N, K, M] = hough(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get data matrix X
  if(length(varargin) >= 1)
    X = varargin{1};
  else
    error('Missing data X')
  end
  
  % Get amount of sloped lines
  if(length(varargin) >= 2)
    p = varargin{2};
    if(p <= 0)
      error('Line length threshold in precent needs to be above 0');
    end
    if(p > 1)
      p = 1;
    end
  else
    error('Missing line length threshold in precent');
  end

  % Get minimum radius for hough cluster
  if(length(varargin) >= 3)
    epsilon = varargin{3};
  else
    error('Missing minimum radius for hough cluster');
  end

  % Get minimum points for hough cluster
  if(length(varargin) >= 4)
    min_pts = varargin{4};
  else
    error('Missing minimum points for hough cluster');
  end

  % Compute scores for the lines
  [P, r_half] = hough_scores(X, p);

  % Turn the scores matrix into a hough cluster
  [x, y, z, N, index] = hough_cluster(P, epsilon, min_pts);

  % Compute lines
  [K, M] = hough_lines(x, y, z, N, index, r_half);
end

function [x, y, z, N, index] = hough_cluster(P, epsilon, min_pts)
  % Turn matrix P into 3 vectors
  [x, y, z] = find(P);

  % Sort so the longest line comes first
  [z, sorted_indexes] = sort(z, 'descend');

  % Sort the rest
  x = x(sorted_indexes);
  y = y(sorted_indexes);

  % Do dbscatn - All idx values that are 0, are noise
  C = cat(2, x, y);
  index = mi.dbscan(C, epsilon, min_pts);

  % Find the amount of clusters
  N = max(index);

  % Uncomment for test
  %for i = 0:N
  %  scatter3(x(index == i), y(index == i), z(index == i));
  %  hold on
  %end
  %figure
end

function [P, r_half] = hough_scores(X, p)
  % Get the size of X
  [m, n] = size(X);

  % Choose angles between -90 and 90 in radians with 1 degree in step
  angles = -90:1:90;

  % Compute slope K for every angle
  angles(1) = -90 - 1e5;
  angles(181) = 90 + 1e5;
  K = tan(deg2rad(angles));

  % Get length of K
  K_length = length(K);

  % Compute the r_half
  r_half = floor(sqrt(m^2 + n^2));

  % Maximum r value
  r_max = 2*r_half;

  % Create points holder P
  P = zeros(180, r_max);

  % Create max index
  max_index = 180*r_max;

  % Collect the points for the most common lines
  for i = 1:m
    for j = 1:n
      % Check if the coordinate X(i, j) belongs to an edge
      if(X(i, j) <= eps)
        % No edge here
        continue
      end

      % Compute M from straight line equation
      M = j - K*i;

      % Find x that finds a minimal r
      x = -K.*M./(1 + K.^2);

      % Compute y
      y = K.*x + M;

      % Compute r and make it to an integer
      r = round(sqrt(x.^2 + y.^2));

      % This is a special case when we want to track the direction of r
      r(y > 0) = r(y > 0) + r_half;

      % Compute the angles
      angles = atan2(y, x);

      % Make sure that the angles are not negative
      angles(angles < 0) = angles(angles < 0) + pi;

      % Turn them into degrees and add +1 because of the indexing
      angles = round(rad2deg(angles)) + 1;

      % Save the indexes in column major
      indexes = r*180 + angles;

      % Avoid indexes that are larger than max index
      indexes(indexes > max_index) = [];

      % Check if there are duplicates
      P(indexes) = P(indexes) + 1;
    end
  end

  % p is precent variable that describes the threshold for a line definition - Small lines avoid
  threshold = max(P(:)) * p;
  P(P < threshold) = 0;
end

function [K, M] = hough_lines(x, y, z, N, index, r_half)
  % Create K and M - They are holders for the output
  K = zeros(1, N);
  M = zeros(1, N);

  % Fill
  for i = 1:N
    % Find the maximum value at z-axis of a specific class ID
    [~, max_index] = max(z(index == i));

    % Get the angles and take -1 because we did +1 above
    angle = x(index == i)(max_index) - 1;

    % Important to take -1 because indexes = sub2ind(size(P), angles, r) (a function that been used before) cannot accept r = 0, but indexes = r*180 + angles; can that
    r = y(index == i)(max_index) - 1;

    % This is the trick to make sure r pointing at the right direction
    if(r > r_half)
      r = r - r_half;
    else
      r = -r;
    end

    % Make sure that the angle is not deliberately, purposefully and exactly 90
    if(abs(90 - angle) <= 1e-05)
      angle = angle + 1e-05;
    end

    % y = k*x + m can be expressed as x*sin(angle) + y*cos(angle) = r
    angle = deg2rad(angle);
    K(i) = sin(angle)/-cos(angle);
    M(i) = - r/-cos(angle);
  end
end
