% Hough transform - Line detection algorthm
% Input: X(Data matrix of an edge image), N(Amout of sloped lines), p(Line length threshold in precent)
% Output: K(Slopes), M(Bias), R(Projected distance), T(Radians angle of the projected distance)
% Example 1: [K, M, R, T] = mi.hough(X, N);
% Example 2: [K, M, R, T] = mi.hough(X, N, p);
% Author: Daniel Mårtensson, 10 September 2023

function [K, M, R, T] = hough(varargin)
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
    N = varargin{2};
  else
    error('Missing amount of sloped lines')
  end

  % Get amount of sloped lines
  if(length(varargin) >= 3)
    p = varargin{3};
    if(p > 1)
      p = 1;
    end
  else
    p = 0;
  end

  % Compute scores for the lines
  P = compute_scores(X, p);

  % Turn P into vectors
  [x, y, z] = matrix_into_vectors(P);

  % Compute lines
  radius = 10;
  [K, M, R, T] = compute_lines(P, N, radius);
end

function [x, y, z] = matrix_into_vectors(P)
  [x, y, z] = find(P);
end

function P = compute_scores(X, p)
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
  P = zeros(270, r_max);

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

      % Compute theta and make sure theta is not negative
      v = rad2deg(atan2(y, x));
      theta = floor(90 + v);

      % If theta is deliberately, purposefully and exactly 180
      % then the slope is going to be infinity large
      % Make sure it's either 179 or 181 by random choice
      theta(theta == 180) = 180 + sign(rand(1));

      % Avoid values that are larger than r_max
      theta(r > r_max) = [];
      r(r > r_max) = [];

      % Add + 1
      indices = sub2ind(size(P), theta, r);
      P(indices) = P(indices) + 1;
    end
  end

  % This is the non vectorized code
  %for i = 1:m
  %  for j = 1:n
      % Check if the coordinate X(i, j) belongs to an edge
  %    if(X(i, j) <= eps)
       % No edge here
  %      continue
  %    end

      % Compute the r and theta from the pixel
  %    for k = 1:K_length
        % Compute M from straight line equation
  %     M = j - K(k)*i;

        % Find x that finds a minimal r
  %     x = -Kk(k)*Mk/(1 + Kk(k)^2);

        % Compute y
  %     y = K(k)*x + M;

        % Compute r and make it to an integer
  %     r = floor(sqrt(x^2 + y^2)) + 1; % + 1 is just for indexing

        % Compute theta and make sure theta is not negative
  %     v = rad2deg(atan2(y, x));
  %     theta = floor(90 + v);

        % If theta is deliberately, purposefully and exactly 180
        % then the slope is going to be infinity large
        % Make sure it's either 179 or 181 by random choice
        %if(theta == 180)
        %  theta = 180 + sign(rand(1));
        %end

        % Sometimes r kan be larger than R
  %     if(r <= r_max)
  %        P(theta, r) = P(theta, r) + 1;
  %      end
  %    end
  %  end
  %end

  % p is precent variable that describes the threshold for a line definition - Small lines avoid
  longest_top = max(P(:));
  P(P < longest_top*p) = 0;
end

function [K, M, R, T] = compute_lines(P, N, radius)
  % Update size for P
  [m, n] = size(P);

  % Sort P as it was a vector
  [~, index] = sort(P(:), 'descend');

  % Create K, M, R and T - They are holders for the output
  K = zeros(1, N);
  M = zeros(1, N);
  R = zeros(1, N);
  T = zeros(1, N);

  % Fill K and M
  count = 1;
  for k = 1:m*n
    % Find the theta and r for the N largest value
    [theta, r] = ind2sub([m, n], index(k));

    % Take minus 90 because we did + 90 above
    theta = theta - 90;

    % Check if it's not the same theta and r again
    if(k > 1)
      if(compute_violate(theta, r, T, R, radius))
        continue
      end
    end

    % y = k*x + m can be expressed as x*sin(theta) + y*cos(theta) = r
    v = deg2rad(theta);
    K(count) = sin(v)/-cos(v);
    M(count) = - r/-cos(v);
    R(count) = r;
    T(count) = theta;

    % Count
    count = count + 1;
    if(count > N)
      break;
    end
  end
end

function violate = compute_violate(theta, r, T, R, radius)
  % Check if they violate
  theta_violate = abs(theta - T) < radius;
  r_violate = abs(r - R) < radius;

  % Check if they both violate
  violate = and(length(find(r_violate > 0)), length(find(theta_violate > 0)));

  %  violate = false;
  %  for j = 1:count
  %    % Find the difference
  %    x = abs(theta - T(j));
  %    y = abs(r - R(j));

       % Check the difference is lower than radius
  %    if(and(x < radius, y < radius))
  %      violate = true;
  %      break;
  %    end
  %  end
end
