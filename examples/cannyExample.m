% Close all
close all

% Read image
image = imread(fullfile('..', 'data', 'way.jpg'));

% Turn to grey scale
if(size(image, 3) == 3)
  image = rgb2gray(image);
end

% Compute gradients and orientations
E = mi.canny(image);

% Show original image
subplot(1, 2, 1);
imshow(image);
title('Original image');

% Show gradient image
subplot(1, 2, 2);
imshow(uint8(E));
title('Edge image');
