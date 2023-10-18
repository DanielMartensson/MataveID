% Local Binary Pattern of the centrum of an image
% Input: X(part of an image), radius, init_angle(where to begin with counting), lbp_bit(enter: 8, 16, 24, 32)
% Output: descriptor(binary value)
% Example 1: [descriptor] = mi.lbp(X, radius, init_angle, lbp_bit);
% Author: Daniel Mårtensson, Oktober 18:e 2023

function [descriptor] = lbp(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get image
  if(length(varargin) >= 1)
    X = varargin{1};
  else
    error('Missing image')
  end

  % Get radius
  if(length(varargin) >= 2)
    radius = varargin{2};
  else
    error('Missing radius')
  end

  % Get init angle
  if(length(varargin) >= 3)
    init_angle = varargin{3};
  else
    init_angle = 0;
  end

  % Get lbp_bit
  if(length(varargin) >= 4)
    lbp_bit = varargin{4};
  else
    lbp_bit = 8;
  end

  % Constants
	angles8 = [ 0.0, 0.7854, 1.5708, 2.3562, 3.1416, 3.927, 4.7124, 5.4978 ];
	angles16 = [ 0.0, 0.3927, 0.7854, 1.1781, 1.5708, 1.9635, 2.3562, 2.7489, 3.1416, 3.5343, 3.927, 4.3197, 4.7124, 5.1051, 5.4978, 5.8905 ];
	angles24 = [ 0.0, 0.2618, 0.5236, 0.7854, 1.0472, 1.3090, 1.5708, 1.8326, 2.0944, 2.3562, 2.6180, 2.8798, 3.1416, 3.4034, 3.6652, 3.9270, 4.1888, 4.4506, 4.7124, 4.9742, 5.2360, 5.4978, 5.7596, 6.0214 ];
	angles32 = [ 0.0, 0.19635, 0.3927, 0.58905, 0.7854, 0.98175, 1.1781, 1.3744, 1.5708, 1.7671, 1.9635, 2.1598, 2.3562, 2.5525, 2.7489, 2.9452, 3.1416, 3.3379, 3.5343, 3.7306, 3.927, 4.1233, 4.3197, 4.516, 4.7124, 4.9087, 5.1051, 5.3014, 5.4978, 5.6941, 5.8905, 6.0868 ];

  % Center coordinates
  [m, n] = size(X);
	half_m = m / 2 + 1;
	half_n = n / 2 + 1;

  % Get the center value
	P = X(half_m, half_n);

  % Initial parameters
	switch (lbp_bit)
	case 8
		angles = angles8;
	case 16
		angles = angles16;
	case 24
		angles = angles24;
	case 32
		angles = angles32;
	otherwise
		angles = angles8;
  end

  % Create the descriptor
	descriptor = 0;
	for i = 1:length(angles)
		% Compute the angle
		angle = init_angle + angles(i);

		% Find the circle coordinates
		coordinate_m = round(half_m + radius * cos(angle));
		coordinate_n = round(half_n + radius * sin(angle));

		% Check if the coordinate has a brighter color than centrum P
		descriptor = bitset(descriptor, i, X(coordinate_m, coordinate_n) > P);
	end
end
