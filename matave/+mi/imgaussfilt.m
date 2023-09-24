% Gaussian 2D filter
% Input: Data matrix(X)
% Output: Y(Filtered data matrix)
% Example 1: [Y] = mi.imgaussfilt(X);
% Example 2: [Y] = mi.imgaussfilt(X, sigma);
% Author: Daniel Mårtensson, 24 September 2023

function [Y] = imgaussfilt(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing input')
  end

  % Get state input
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
  [x, y] = meshgrid(1:kernel_size, 1:kernel_size);

  % Create gaussian 2D kernel
  K_g = 1/(2*pi*sigma^2)*exp(-(x.^2 + y.^2)/(2*sigma^2));

  % Normalization
  K_g = K_g / sum(K_g(:));

  % Do conv2 with FFT
  Y = conv2_fft(X, K_g);
end

function G = conv2_fft(X, K)
  % Create kernel
  [m, n] = size(X);
  kernel = zeros(m, n);
  [m, n] = size(K);
  kernel(1:m, 1:n) = K;

  % Do FFT2 on X and kernel
  A = fft2(X);
  B = fft2(kernel);

  % Compute the convolutional matrix - abs to remove zero imaginary numbers
  G = abs(ifft2(A.*B));
end
