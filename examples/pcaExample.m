% First clear and close all figures
clear
close all

% Create data where every colum is a variable
X = [1 3 10;
    2 4 12;
    3 6 13;
    4 10 16;
    5 13 20;
    30 34 104;
    31 56 120;
    32 74 127;
    33 80 128;
    34 89 131;
    35 103 139];

% Plot original data
scatter3(X(:, 1), X(:, 2), X(:, 3))
title('Original 3D data', 'FontSize', 20)

% Reduce how many dimensions
c = 2;

% Do PCA for 2D
[P, W] = pca(X, c);

% Show 2D reduction
figure
scatter(P(:, 1), P(:, 2));
grid
title('Dimension reduction to 2D', 'FontSize', 20)

% Reduce how many dimensions
c = 1;

% Do PCA for 1D
[P, W] = pca(X, c);
figure
scatter(P(:, 1), 0*P(:, 1));
grid
title('Dimension reduction to 1D', 'FontSize', 20)
