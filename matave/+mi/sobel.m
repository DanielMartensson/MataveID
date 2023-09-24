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
  Gx = mc.conv2fft(X, K_x);
  Gy = mc.conv2fft(X, K_y);

  % Compute the gradients
  G = sqrt(Gx.^2 + Gy.^2);

  % Compute the orientations
  O = atan2d(Gy, Gx);
end
