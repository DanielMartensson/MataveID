% Close all
close all

% Read image
image = imread('..', 'data', 'wink.gif');

% Turn to grey scale
if(size(image, 3) == 3)
  image = rgb2gray(image);
end

% Compute gradients and orientations
[G, O] = mi.sobel(input_image);

% Show original image
subplot(1, 2, 1);
imshow(input_image);
title('Original image');

% Show gradient image
subplot(1, 2, 2);
imshow(uint8(G));
title('Gradient image');
