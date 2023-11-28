% Convolution via FFT2
% Input: X(Data matrix), K(Kernel matrix)
% Output: C(Filtered data matrix)
% Example 1: [C] = mc.conv2fft(X, K);
% Author: Daniel Mårtensson, 24 September 2023

function [C] = conv2fft(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing input')
  end

  % Get input matrix X
  if(length(varargin) >= 1)
    X = varargin{1};
  else
    error('Missing input data matrix X')
  end

  % Get the sigma
  if(length(varargin) >= 2)
    K = varargin{2};
  else
    error('Missing kernel data matrix K')
  end

  t = varargin{3};

  % Create kernel
  [m, n] = size(X);
  kernel = zeros(m, n);
  [m, n] = size(K);

  % Compute the sizes
  m_middle = ceil(m/2);
  n_middle = ceil(n/2);

  % Insert kernel
  if(t == 1)
  kernel(1:m_middle, 1:n_middle) = K(m_middle:end, n_middle:end);
  kernel(end-m_middle+1:end, 1:n_middle) = K(1:m_middle, n_middle:end);
  kernel(1:m_middle, end-n_middle+1:end) = K(m_middle:end, 1:n_middle);
  kernel(end-m_middle+1:end, end-n_middle+1:end) = K(m_middle:end,n_middle:end);
elseif(t == 2)
    kernel(1:m_middle, 1:n_middle) = K(m_middle:end, n_middle:end);
    kernel(end, 1:n_middle) = K(1, n_middle:end);
    kernel(1:m_middle, end) = K(m_middle:end, 1);
    kernel(end, end) = K(1,1);
  end

  % Do FFT2 on X and kernel
  A = fft2(X);
  B = fft2(kernel);

  % Compute the convolutional matrix - real to remove zero imaginary numbers
  C = real(ifft2(A.*B));
end
