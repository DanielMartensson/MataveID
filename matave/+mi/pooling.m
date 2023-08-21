% Pooling - Reduce an image with different techniques
% Input: image(A matrix), pooling_method(1 = Max pooling, 2 = Average pooling, 3 = Shape pooling), p = Pooling pixel size
% Output: P(Pooled image a.k.a reduced in pixels)
% Example 1: [P] = mi.pooling(image, pooling_method, p);
% Author: Daniel Mårtensson, Augusti 21 2023
% Notice: There are an equivalent C code for pooling inside Control repository

function [P] = pooling(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get image
  if(length(varargin) >= 1)
    image = varargin{1};
  else
    error('Missing image')
  end

  % Get pooling method
  if(length(varargin) >= 2)
    pooling_method = varargin{2};
  else
    error('Missing pooling method')
  end

  % Get pooling pixel size
  if(length(varargin) >= 3)
    p = varargin{3};
  else
    error('Missing pooling pixel size')
  end

  % Size of A
  [m, n] = size(image);

  % P size
  h = floor(m / p);
  w = floor(n / p);
  P = zeros(h, w);

  % Minimal case
  a = mean(image(:));
  b = max(image(:));

  % Process
  for i = 1:h
    for j = 1:w
      % Cut
      start_row = (i - 1) * p + 1;
      stop_row = i * p;
      start_column = (j - 1) * p + 1;
      stop_column = j * p;
      B = image(start_row:stop_row, start_column:stop_column);

      % Do pooling
      switch(pooling_method)
      case 1
        P(i, j) = max(B(:)); % Max pooling
      case 2
        P(i, j) = mean(B(:)); % Average pooling
      case 3
        P(i, j) = mean(B(:))/a*b; % Shape pooling
      otherwise
        error('Unknown pooling method');
      end
    end
  end
end
