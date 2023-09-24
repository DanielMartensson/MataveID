% Sobel filter
% Input: X(Data matrix)
% Output: G(Gradients), O(Orientations)
% Example 1: [G, O] = mi.sobel(X);
% Author: Daniel Mårtensson, 6 September 2023

function [G, O] = sobel(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing input')
  end

  % Get X
  X = varargin{1};

  % Gray scaled image
  if(size(X, 3) > 1)
    X = rgb2gray(X);
  end

  % Create kernels for X-direction and Y-direction
  K_x = [-1 0 1; -2 0 2; -1 0 1];
  K_y = [-1 -2 -1; 0 0 0; 1 2 1];

  % Do conv2 with FFT
  Gx = conv2_fft(X, K_x);
  Gy = conv2_fft(X, K_y);

  % Compute the gradients
  G = sqrt(Gx.^2 + Gy.^2);

  % Compute the orientations
  O = atan2d(Gy, Gx);

end

function G = conv2_fft(X, K)
  % Create kernel
  [m, n] = size(X);
  kernel = zeros(m, n);
  [m, n] = size(K);

  % Compute the sizes
  m_middle = ceil(m/2);
  n_middle = ceil(n/2);

  % Insert kernel
  kernel(1:m_middle, 1:n_middle) = K(m_middle:end, n_middle:end);
  kernel(end, 1:n_middle) = K(1, n_middle:end);
  kernel(1:m_middle, end) = K(m_middle:end, 1);
  kernel(end, end) = K(1,1);

  % Do FFT2 on X and kernel
  A = fft2(X);
  B = fft2(kernel);

  % Compute the convolutional matrix - abs to remove zero imaginary numbers
  G = abs(ifft2(A.*B));
end
