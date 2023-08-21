% Check if it's Octave or MATLAB
if ~isempty(ver('Octave'))
  pkg load image
end

% Load image
file = fullfile('..','Data\yale\Class 1\','centerlight.gif');
image = imread('C:\Users\dmn\GitHub\CControl\src\CControl\Documents\Data\yale\Class 1\centerlight.gif');

% Uncomment if image is an RBG image
%image = double(rgb2gray(image));

% Do pooling
p = 3;
max_pooling = uint8(mi.pooling(image, 1, p));
average_pooling = uint8(mi.pooling(image, 2, p));
shape_pooling = uint8(mi.pooling(image, 3, p));

% Plot images
montage([max_pooling average_pooling shape_pooling])
title('Max pooling     Average pooling     Shape pooling', 'FontSize', 20);
