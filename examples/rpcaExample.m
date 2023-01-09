clc; clear; close all;

X = imread('bob.jpg'); % Load Mr Bob
X = rgb2gray(X);       % Grayscale 8 bit
X = double(X);         % Must be double 40 => 40.0
[L, S] = rpca(X);      % Start RPCA. Our goal is to get L matrix
figure(1)
imshow(uint8(X))       % Before RPCA
title('Before RPCA - Bob')
figure(2)
imshow(uint8(L))       % After RPCA
title('After RPCA - Bob')