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

% Noisy data
X = [X; 10*randn(10, 3)];

% Remove noise
y = mi.dbscan(X, 50, 2);
X = X(y ~= 0, :);

% Plot original data
cmap = jet(length(X));
scatter3(X(:, 1), X(:, 2), X(:, 3), 50,cmap)
title('Original 3D data', 'FontSize', 20)

% Do KPCA
c = 2;
kernel_type = 'polynomial';
kernel_parameters = [1, 2];
[K, P, W] = mi.kpca(X, c, kernel_type, kernel_parameters);

% Reconstruct
K_reconstructed = W * P;
reconstruction_error = norm(K - K_reconstructed, 'fro') / norm(K, 'fro')

figure
switch(c)
case 3
  scatter3(K_reconstructed(:, 1), K_reconstructed(:, 2), K_reconstructed(:, 3));
case 2
  scatter(K_reconstructed(:, 1), K_reconstructed(:, 2));
case 1
  scatter(K_reconstructed(:, 1), 0*K_reconstructed(:, 1));
end
grid on
title(sprintf('Reconstruction %iD with error %f', c, reconstruction_error), 'FontSize', 20)
