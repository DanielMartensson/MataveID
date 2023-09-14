% Clear
clear all
close all
clc

% Read image
X = imread(fullfile('..', 'data', 'test_hough.png'));

% If the image is color
if(size(X, 3) > 1)
  X = rgb2gray(X);
end

% Plot the image
imshow(X);

% Do hough transform
p = 0.3; % Percentage definition of a line e.g all lines shorter than p times longest line, should be classes as a non-line
epsilon = 10; % Minimum radius for hough cluster
min_pts = 2; % Minimum points for hough cluster
[N, K, M] = mi.hough(X, p, epsilon, min_pts);

% Plot the lines together with the image
[~, n] = size(X);
x = linspace(0, n);
hold on
for i = 1:N
  y = K(i)*x + M(i);
  plot(x, y)
end
