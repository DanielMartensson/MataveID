% Plot bode spectral analysis plot using Fast Fourier Transform
% Input: y(frequency output), t(time)
% Output: mag(magnitude), phase, wout(frequencies)
% Example 1: [mag, phase, wout] = spa(y, t);
% Author: Daniel Mårtensson, November 2017

function [mag, phase, wout] = spa(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
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
  
  Ts = t(2)-t(1); % Sampling time
  Fs = 1/Ts; % Sampling rate
  % Do FFT
  F = fft(y, Fs);
  Y = abs(F);
  
  % Compute the frequencies 
  freq = (0:Fs-1)(1:end/2);
  % Compute the amplitudes
  Y = Y(1:end/2)/length(Y)*2;
  F = F(1:length(freq));
  
  subplot(2, 1,1)
  semilogx(freq, 20*log10(Y))
  ylabel('Magnitude [dB]')
  subplot(2,1,2)
  semilogx(freq, angle(F)*180/pi);
  ylabel('Phase [Deg]')
  xlabel('Frequency [rad/s]')
  
  % Return values
  mag = 20*log10(Y);
  phase = angle(F)*180/pi;
  wout = freq;

end