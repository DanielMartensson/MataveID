% Plot a bode diagram from frequency data
% Input: u(frequency input), y(frequency response), fs(sampleTime)
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

  % Get the sampleTime
  if(length(varargin) >= 3)
    sampleTime = varargin{3};
  else
    error('Missing time');
  end

  % Get the size of u or y and w
  [m, n] = size(y);

  % Do Fast Fourier Transform for every input signal
  for i = 1:m

    % Do FFT
    Nfft = 32768; % 2^15 is a good number to get a clean plot
    fy = fft(y(i, :),Nfft);
    fu = fft(u(i, :) ,Nfft);
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
    BodeAngles = zeros(1, length(H));

    % This fixing the 360 degrees problem
    R = 0;
    for k = 1:length(H)-1
      % Get the angle in degrees
      a1 = angle(H(k)) * 180/pi;
      a2 = angle(H(k+1)) * 180/pi;

      % Add angle
      BodeAngles(k) = a1 + R;

      % Check if we are aboute 90
      if(and(a2 > 170, a1 < -170))
        R = R - 360
      elseif(and(a1 > 170, a2 < -170))
        R = R + 360
      end
    end
    BodeAngles(end) = angle(H(end)) * 180/pi + R;

    % Plot
    semilogx(freq, BodeAngles);
    ylabel('Phase [deg]');
    xlabel('Frequency [rad/s]');
    grid on
  end
end
