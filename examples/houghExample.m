% Clear
clear all
close all
clc

% Read image
X = imread('test_hough.png');

% If the image is color
if(size(X, 3) > 1)
  X = rgb2gray(X);
end

% Plot the image
imshow(X);

% Do hough transform
N = 6; % Number of lines
radius = 10; % This tuning parameter prevents the algorithm to re-select the same line again
[K, M] = mi.hough(X, N, radius);

% Plot the lines together with the image
[~, n] = size(X);
x = linspace(0, n);
hold on
for i = 1:N
  y = K(i)*x + M(i);
  plot(x, y)
end
