% Binary Robust Invariant Scalable Keypoints
% Input: X(image), sigma1(background filtering), sigma2(descriptor filtering), threshold_sobel(corner filtering), threshold_fast(corner threshold), fast_method(enter: 9, 10, 11, 12)
% Output: histogram(classification data), X1(filtered background), X2(filtered data for descriptors), G(gradients for the corners), corners, scores(corner scores)
% Example 1: [histogram, X1, X2, G, corners, scores] = mi.brisk(X, sigma1, sigma2, threshold_sobel, threshold_fast, fast_method);
% Author: Daniel Mårtensson, Oktober 19:e 2023

function [histogram, X1, X2, G, corners, scores] = brisk(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get image
  if(length(varargin) >= 1)
    X = varargin{1};
  else
    error('Missing image')
  end

  % Get sigma1
  if(length(varargin) >= 2)
    sigma1 = varargin{2};
  else
    error('Missing sigma1')
  end

  % Get sigma2
  if(length(varargin) >= 3)
    sigma2 = varargin{3};
  else
    error('Missing sigma2')
  end

  % Get threshold sobel
  if(length(varargin) >= 4)
    threshold_sobel = varargin{4};
  else
    error('Missing threshold sobel')
  end

  % Get threshold fast
  if(length(varargin) >= 5)
    threshold_fast = varargin{5};
  else
    error('Missing threshold fast')
  end

  % Get fast method
  if(length(varargin) >= 6)
    fast_method = varargin{6};
  else
    error('Missing fast method')
  end

  % Compute rows and columns
  [m, n] = size(X);

  % Apply gaussian blurr for making small objects not recognizable
  if(sigma1 > 0)
    X1 = mi.imgaussfilt(X, sigma1);
  end

  % Apply sobel operator onto the blurred image X1 for finding the shapes - Also compute the orientations for later use
  [G, O] = mi.sobel(X1);

  % Apply FAST on the gradients for finding interests points onto the shapes
  G(G <= threshold_sobel) = 0;

  % Use FAST
  [corners, scores] = mi.fast(G, threshold_fast, fast_method);

  % Make another blur for computing the descriptors
  if(sigma2 > 0)
    X2 = mi.imgaussfilt(X1, sigma2);
  end

  % Compute the descriptors
  radius = [4, 8, 12, 16];
  lbp_bit = [8, 16, 24, 32];
  histogram = zeros(1, 1024);
  for i = 1:length(corners)
    % Get coordinates for the interest points
    x = corners(i, 1);
    y = corners(i, 2);

    % Find the descriptors
    for j = 1:4
      % Compute the squre area limits
      x_min = x - radius(j);
      x_max = x + radius(j);
      y_min = y - radius(j);
      y_max = y + radius(j);

      % Check if the O_part is not at the edge of the image
      if(and(x_min >= 1, y_min >= 1, x_max <= n, y_max <= m))
        % Cut one part from the orientation matrix O
        O_part = O(y_min:y_max, x_min:x_max);

        % Then find the principal orientation, a.k.a the mean value of O_part
        init_angle = mean(O_part(:));

	% Find the rotated descriptor index with different radius
	% If lgb_bit is 8-bit, then descriptor_index will be from 1 to 256
	% If lgb_bit is 16-bit, then descriptor_index will be from 257 to 512
	% If lgb_bit is 24-bit, then descriptor_index will be from 513 to 768
	% If lgb_bit is 32-bit, then descriptor_index will be from 769 to 1024
	descriptor_index = mi.lbp(X2, x, y, radius(j), init_angle, lbp_bit(j)) + 1;

        % Scale descriptor index to 8 bit
        switch(j)
          % case 1 is just 8-bit
        case 2
          % 16-bit
          descriptor_index = descriptor_index / 0x100 + 256; % Index from 257 to 512
        case 3
          % 24-bit
          descriptor_index = descriptor_index / 0x10000 + 512; % Index from 513 to 768
        case 4
          % 32-bit
          descriptor_index = descriptor_index / 0x1000000 + 768; % Index from 769 to 1024
        end

        % Add to histogram
        histogram(descriptor_index) = histogram(descriptor_index) + 1;
      end
    end
  end
end
