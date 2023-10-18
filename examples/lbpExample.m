% Close all
close all

% Read image
X = imread(fullfile('..', 'data', 'lab.pgm'));

% Make image greyscale
if size(X, 3) > 1
  X =  rgb2gray(X);
else
  X = double(X);
end

% Compute Local Binary Pattern
radius = 100;
init_angle = 0;
lbp_bit = 32;
x = 110;
y = 110;
descriptor = mi.lbp(X, x, y, radius, deg2rad(init_angle), lbp_bit);
fprintf('%i = 0b%s\n', descriptor, dec2bin(descriptor))
