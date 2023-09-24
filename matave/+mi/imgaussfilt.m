% Gaussian 2D filter
% Input: X(Data matrix), Sigma(Standard deviation)
% Output: Y(Filtered data matrix)
% Example 1: [Y] = mi.imgaussfilt(X);
% Example 2: [Y] = mi.imgaussfilt(X, sigma);
% Author: Daniel Mårtensson, 24 September 2023

function [Y] = imgaussfilt(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing input')
  end

  % Get data matrix X
  if(length(varargin) >= 1)
    X = varargin{1};
  else
    error('Missing input data matrix X')
  end

  % Get the sigma
  if(length(varargin) >= 2)
    sigma = varargin{2};
  else
    sigma = 1;
  end

  % Gray scaled image
  if(size(X, 3) > 1)
    X = rgb2gray(X);
  end

  % Create gaussian kernel size
  kernel_size = round(6 * sigma);

  % Create mesh grid
  [x, y] = meshgrid(-kernel_size:kernel_size, -kernel_size:kernel_size);

  % Create gaussian 2D kernel
  K_g = 1/(2*pi*sigma^2)*exp(-(x.^2 + y.^2)/(2*sigma^2));

  % Do conv2 with FFT
  Y = mc.conv2fft(X, K_g);

  % Give the same brightness
  Y = Y*sum(X(:))/sum(Y(:));
end
