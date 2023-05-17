% Plot bode spectral analysis plot using Fast Fourier Transform
% Input: y(frequency output), t(time)
% Output: amp(amplitude), wout(frequencies)
% Example 1: [amp, wout] = mi.spa(y, t);
% Author: Daniel Mårtensson, November 2017
% Update 2022-10-27 with better frequencies and amplitudes

function [amp, wout] = spa(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get output
  if(length(varargin) >= 1)
    y = varargin{1};
  else
    error('Missing output');
  end

  % Get time
  if(length(varargin) >= 2)
    t = varargin{2};
  else
    error('Missing time');
  end

  % Get sampling rate
  sampleTime = t(2)-t(1);
  Fs = 1/sampleTime;

  % Do FFT
  F = fft(y);
  Y = abs(F);

  % Compute the frequencies
  n = length(y);
  freq = (0:n-1)*(Fs/n);

  % Compute the amplitudes
  Y = Y/n*2;

  % Cut away the mirror
  Y = Y(1:end/2);
  freq = freq(1:end/2);

  plot(freq, Y)
  ylabel('Amplitude')
  xlabel('Frequency [Hz]')
  grid on

  % Return values
  amp = 20*log10(Y);
  wout = freq;

end
