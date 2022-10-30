% Plot a bode diagram from frequency data
% Input: u(frequency input), y(frequency response), sampleTime
% Example: idbode(u, y, fs)
% Author: Daniel Mårtensson, April 2020
% Update 2022, Oktober 29:e Better plot

function idbode(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get input
  if(length(varargin) >= 1)
    u = varargin{1};
  else
    error('Missing input')
  end

  % Get output
  if(length(varargin) >= 2)
    y = varargin{2};
  else
    error('Missing output')
  end

  % Get the sample time
  if(length(varargin) >= 3)
    sampleTime = varargin{3};
  else
    error('Missing sample time');
  end

  % Get the size of u or y and w
  [m, n] = size(y);
  
  % Check if u has the same length as y
  if(n ~= size(u, 2))
    error('Input u need to have the same length as output y')
  end
  
  % Check if u has the same rows as y
  if(m ~= size(u, 1))
    error('Input u need to have the same rows as output y')
  end

  % Do Fast Fourier Transform for every input signal
  for i = 1:m

    % Do FFT
    Nfft = 32768; % 2^15 is a good number to get a clean plot
    fy = fft(y(i, :), Nfft);
    fu = fft(u(i, :), Nfft);
    H = fy./fu;

    % Frequencies
    freq = [0:Nfft-1]/Nfft*2*pi*sampleTime;

    % Avoid zero
    freq(1) = freq(2);

    % Windowing - Half
    H = H(1:end/2);
    freq = freq(1:end/2);

    % Plot the bode diagram of measurement data
    figure('Name', sprintf(strcat('Bode diagram: ', num2str(i))))
    subplot(2,1,1)
    semilogx(freq, 20*log10(abs(H)));
    ylabel('Magnitude [dB]');
    grid on
    subplot(2,1,2)

    % Create the bode angles
    BodeAngles = angle(H) * 180/pi;
    semilogx(freq, BodeAngles);
    ylabel('Phase [deg]');
    xlabel('Frequency [rad/s]');
    grid on
  end
end
