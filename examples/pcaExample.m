% First clear and close all figures
clear
close all

% Create data
X = [-3244 5324 1345;
    10 30 100;
    20 40 93;
    30 60 163;
    60 100 126;
    55 13 134;
    306 34 104;
    316 56 120;
    326 74 127;
    337 80 128;
    347 89 131;
    358 103 139;
    -31 -56 -120;
    -32 -74 -127;
    -33 -80 -128;
    -34 -89 -131;
    -35 -103 -139;
    700 600 500;
    1000 1000 1000;
    -3231 4345 -4352;
    -2342 4356 3453;
    -2364 4326 3353;
    658 143 1692];

X = [X; 10*randn(10, 3)];

% Plot original data
cmap = jet(length(X));
scatter3(X(:, 1), X(:, 2), X(:, 3), 50,cmap)
title('Original 3D data', 'FontSize', 20)

% Do PCA for 3D
c = 3;
[P, W] = Mid.pca(X, c);
figure
scatter3(P(:, 1), P(:, 2), P(:, 3), 50,cmap);
grid on
title('Dimension transformation to 3D', 'FontSize', 20)

% Do PCA for 2D
c = 2;
[P, W] = Mid.pca(X, c);
figure
scatter(P(:, 1), P(:, 2), 20,cmap);
grid on
title('Dimension reduction to 2D', 'FontSize', 20)

% Do PCA for 1D
c = 1;
[P, W] = Mid.pca(X, c);
figure
scatter(P(:, 1), 0*P(:, 1), 50,cmap);
grid on
title('Dimension reduction to 1D', 'FontSize', 20)
