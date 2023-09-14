% Hough transform - Line detection algorthm by using hough transform and DBscan
% Input: X(Data matrix of an edge image), p(Line length threshold in precent), epsilon(Minimum radius for hough cluster), min_pts(Minimum points for hough cluster)
% Output: N(Number of lines), K(Slopes), M(Bias), R(Projected distance), T(Radians angle of the projected distance)
% Example 1: [N, K, M, R, T] = mi.hough(X, p, epsilon, min_pts);
% Author: Daniel Mårtensson, 14 September 2023

function [N, K, M, R, T] = hough(varargin)
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
  P = hough_scores(X, p);

  % Turn the scores matrix into a hough cluster
  [A, N, index] = hough_cluster(P, epsilon, min_pts);

  % Compute lines
  [K, M, R, T] = hough_lines(A, N, index);
end

function [A, N, index] = hough_cluster(P, epsilon, min_pts)
  % Turn matrix P into 2 vectors
  [x, y, z] = find(P);

  % Do dbscan - All idx values that are 0, are noise
  A = [x y];
  index = mi.dbscan(A, epsilon, min_pts);

  % Add the z axis as well
  A = [x y z];

  % find the amount of clusters
  N = max(index);

  % Uncomment for test
  %for i = 0:N
  %  scatter3(A(index == i, 1), A(index == i, 2), A(index == i, 3));
  %  hold on
  %end
  %figure
end

function P = hough_scores(X, p)
  % Get the size of X
  [m, n] = size(X);

  % Choose angles between -90 and 90 in radians with 1 degree in step
  angles = -90:1:90;

  % Compute slope K for every angle
  K = tan(deg2rad(angles));

  % Get length of K
  K_length = length(K);

  % Maximum r value
  r_max = floor(sqrt(m^2 + n^2));

  % Create points holder P
  P = zeros(180, r_max);

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
      r = floor(sqrt(x.^2 + y.^2)) + 1; % + 1 is just for indexing

      % Compute the angles
      angles = atan2(y, x);

      % Make sure that the angles are not negative
      angles(angles < 0) = angles(angles < 0) + pi;

      % Turn them into degrees
      angles = floor(rad2deg(angles)) + 1;

      % If angles is deliberately, purposefully and exactly 90
      % then the slope is going to be infinity large
      % Make sure theta is either 179 or 181 by random choice
      angles(angles == 90) = 90 + sign(rand(1));

      % Avoid values that are larger than r_max
      angles(r > r_max) = [];
      r(r > r_max) = [];

      % Add + 1
      indices = sub2ind(size(P), angles, r);
      P(indices) = P(indices) + 1;
    end
  end

  % p is precent variable that describes the threshold for a line definition - Small lines avoid
  longest_top = max(P(:));
  P(P < longest_top*p) = 0;
end

function [K, M, R, T] = hough_lines(A, N, index)
  % Create K, M, R and T - They are holders for the output
  K = zeros(1, N);
  M = zeros(1, N);
  R = zeros(1, N);
  T = zeros(1, N);

  % Fill
  for i = 1:N
    % Get the columns for class ID number i
    B = A(index == i, :);

    % Find the maximum value at third column, which is the z-axis column
    [~, max_index] = max(B(:, 3));

    % Get the theta and r, which is the x-axis and y-axis column
    b = B(max_index, 1:2);
    angles = b(1);
    r = b(2);

    % y = k*x + m can be expressed as x*sin(angles) + y*cos(angles) = r
    v = deg2rad(angles);
    K(i) = sin(v)/-cos(v);
    M(i) = - r/-cos(v);
    R(i) = r;
    T(i) = angles;
  end
end
