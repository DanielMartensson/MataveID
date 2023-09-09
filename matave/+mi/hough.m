% Hough transform - Line detection algorthm
% Input: X(Data matrix of an edge image), N(Amout of sloped lines), radius(This is a way to make sure you don't select the same K and M value again)
% Output: K(Slopes), M(Bias), R(Projected distance), T(Radians angle of the projected distance)
% Example 1: [K, M, R, T] = mi.hough(X, N);
% Example 2: [K, M, R, T] = mi.hough(X, N, radius);
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
    radius = varargin{3};
  else
    radius = 10;
  end

  % Get the size of X
  [m, n] = size(X);

  % Choose angles between -90 and 90 in radians with 1 degree in step
  angles = -90:1:90;

  % Compute slope Kk for every angle
  Kk = tan(deg2rad(angles));

  % Get length of Kk
  Kk_length = length(Kk);

  % Create the longest distance inside the edge image X
  R = ceil(sqrt(m^2 + n^2)) + 1;

  % Create points holder P
  P = zeros(361, R);

  % Collect the points for the most common lines
  for i = 1:m
    % Get x0
    for j = 1:n
      % Check if the coordinate X(i, j) belongs to an edge
      if(X(i, j) <= eps)
        % No edge here
        continue
      end

      % Compute the r and theta from the pixel
      for k = 1:Kk_length
        % Compute Mk from straight line equation
        Mk = j - Kk(k)*i;

        % Find minimal x
        x = -Kk(k)*Mk/(1 + Kk(k)^2);

        % Compute y
        y = Kk(k)*x + Mk;

        % Compute r and make it to an integer
        r = floor(sqrt(x^2 + y^2)) + 1; % + 1 is just for indexing

        % Compute theta and make sure theta is not negative
        theta = 180 + rad2deg(atan2(y, x));
        theta = floor(theta) + 1; % + 1 is just for indexing

        % Sometimes r kan be larger than R
        if(r <= R)
          P(theta, r) = P(theta, r) + 1;
        end
      end
    end
  end

  % Update size for P
  [m, n] = size(P);

  % Sort P as it was a vector
  [~, index] = sort(P(:), 'descend');

  % Create K and M
  K = zeros(1, N);
  M = zeros(1, N);
  R = zeros(1, N);
  T = zeros(1, N);

  % Create past theta and past r
  past_theta = zeros(1, N);
  past_r = zeros(1, N);

  % Fill K and M
  count = 1;
  for k = 1:m*n
    % Find the theta and r for the N largest value
    [theta, r] = ind2sub([m, n], index(k));

    % Take minus 180 because we did + 180 above
    theta = theta - 180;

    % Check if it's not the same theta and r again
    if(k > 1)
      has_been_used = false;
      for j = 1:count
        % Find the difference
        x = abs(theta - past_theta(j));
        y = abs(r - past_r(j));

        % Check the difference is lower than h
        if(and(x < radius, y < radius))
          has_been_used = true;
          break;
        end
      end

      % Check if selected theta and r has been used before
      if(has_been_used)
        continue
      end
    end

    % y = k*x + m can be expressed as x*sin(theta) + y*cos(theta) = r
    v = deg2rad(theta);
    K(count) = sin(v)/-cos(v);
    M(count) = - r/-cos(v);
    R(count) = r;
    T(count) = theta;

    % Remember
    past_theta(count) = theta;
    past_r(count) = r;

    % Count
    count = count + 1;
    if(count > N)
      break;
    end
  end
end
