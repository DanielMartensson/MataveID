% Clear
close all
clear all
clc

% Load image
X = imread(fullfile('..', 'data', 'hus.jpg'));

% Make image greyscale
if size(X, 3) > 1
	X =  rgb2gray(X);
end

% Compute BRISK
sigma1 = 1;             % Backgroun filtering
sigma2 = 6;             % Filtering for the descriptors
threshold_sobel = 127;  % Threshold for the corners
threshold_fast = 50;    % Threshold for the corners
fast_method = 9;        % FAST method: 9, 10, 11, 12
[data, X1, X2, G, corners] = mi.brisk(X, sigma1, sigma2, threshold_sobel, threshold_fast, fast_method);

% Plot
figure
imshow(uint8(X))
hold on
plot(corners(:, 1), corners(:, 2), 'r.');
title('Corner detection')
hold off
figure
imshow(uint8(X1))
title('Gaussian filter - Background')
figure
imshow(uint8(X2))
title('Gaussian filter - For descriptor')
figure
imshow(uint8(G));
title('Sobel filter - For corner/edge detection')
