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
threshold_fast = 60;    % Threshold for the corners
fast_method = 9;        % FAST method: 9, 10, 11, 12
[data, X1, X2, G, corners] = mi.brisk(X, sigma1, sigma2, threshold_sobel, threshold_fast, fast_method);

% Display data
data
