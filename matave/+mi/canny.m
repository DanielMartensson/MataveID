% Canny filter
% Input: data matrix(X)
% Output: E(Edge matrix)
% Example 1: [E] = mi.canny(X);
% Author: Daniel Mårtensson, 21 September 2023

function E = canny(varargin)
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

  % Gray scaled image
  if(size(X, 3) > 1)
    gray_input_img = rgb2gray(X);
  else
    gray_input_img = X;
  end

  % Apply gaussian blurring
  K_g = 1/159*[2 4 5 4 2; 4 9 12 9 4; 5 12 15 12 5; 4 9 12 9 4; 2 4 5 4 2];
  blur_img = conv2_fft(gray_input_img, K_g);

  % Use sobel
  [grad_mag, grad_dir] = mi.sobel(blur_img);

  % Non maximal suppression
  closest_dir = closest_dir_function(grad_dir);
  thinned_output = non_maximal_suppressor(grad_mag, closest_dir);

  % Hysteresis Thresholding
  E = hysteresis_thresholding(thinned_output);
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

function closest_dir_arr = closest_dir_function(grad_dir)
  [m, n] = size(grad_dir);
  closest_dir_arr = zeros(m, n);
  for i = 1:m
    for j = 1:n
      if or(and(grad_dir(i, j) > -22.5, grad_dir(i, j) <= 22.5), and(grad_dir(i, j) <= -157.5, grad_dir(i, j) > 157.5))
        closest_dir_arr(i, j) = 0;
      elseif or(and(grad_dir(i, j) > 22.5, grad_dir(i, j) <= 67.5), and(grad_dir(i, j) <= -112.5, grad_dir(i, j) > -157.5))
        closest_dir_arr(i, j) = 45;
      elseif or(and(grad_dir(i, j) > 67.5, grad_dir(i, j) <= 112.5), and(grad_dir(i, j) <= -67.5 , grad_dir(i, j) > -112.5))
        closest_dir_arr(i, j) = 90;
      else
        closest_dir_arr(i, j) = 135;
      end
    end
  end
end

function thinned_output = non_maximal_suppressor(grad_mag, closest_dir)
  [m, n] = size(grad_mag);
  thinned_output = zeros(m, n);
  for i = 2:m-1
    for j = 2:n-1
      x = closest_dir(i, j);
      y = grad_mag(i, j);
      switch(x)
      case 0
        if and(y > grad_mag(i, j+1), (y > grad_mag(i, j-1)))
          thinned_output(i, j) = y;
        else
          thinned_output(i, j) = 0;
        end
      case 45
        if and(y > grad_mag(i+1, j+1), (y > grad_mag(i-1, j-1)))
          thinned_output(i, j) = y;
        else
          thinned_output(i, j) = 0;
        end
      case 90
        if and(y > grad_mag(i+1, j), (y > grad_mag(i-1, j)))
          thinned_output(i, j) = y;
        else
          thinned_output(i, j) = 0;
        end
      otherwise
        if and(y > grad_mag(i+1, j-1), (y > grad_mag(i-1, j+1)))
          thinned_output(i, j) = y;
        else
          thinned_output(i, j) = 0;
        end
      end
    end
  end
end

function img = DFS(img)
  [m, n] = size(img);
  for i = 2:m - 1
    for j = 2:n - 1
      if img(i, j) == 127
        t_max = max([img(i-1, j-1), img(i-1, j), img(i-1, j+1), img(i, j-1), img(i, j+1), img(i+1, j-1), img(i+1, j), img(i+1, j+1)]);
        if t_max == 255
          img(i, j) = 255;
        end
      end
    end
  end
end

function img = hysteresis_thresholding(img)
  low_ratio = 0.10;
  high_ratio = 0.30;
  img_min = min(img(:));
  img_max = max(img(:));
  diff = img_max - img_min;
  t_low = img_min + low_ratio * diff;
  t_high = img_min + high_ratio * diff;
  temp_img = img;

  % Assign values to pixels
  [m, n] = size(img);
  img(img > t_high) = 255;
  img(img < t_low) = 0;
  img(and(img < t_high, img > t_low)) = 127;

  % Include weak pixels that are connected to a chain of strong pixels
  total_strong = sum(img(:) == 255);
  while true
    % Update DFS
    img = DFS(img);

    % Compute new strong
    new_total_strong = sum(img(:) == 255);

    % Check if there is no change
    if total_strong == new_total_strong
      break;
    end

    % Update past
    total_strong = new_total_strong;
  end

  % Remove weak pixels
  img(img == 127) = 0;
end
