% How much data
l = 50;

% Data for the first class
x1 = 2*randn(1, l);
y1 = 50 + 5*randn(1, l);
z1 = 1:l;

% Data for the second class
x2 = 5*randn(1, l);
y2 = -4 + 2*randn(1, l);
z2 = 2*l:-1:l+1;

% Data for the third class
x3 = 15 + 3*randn(1, l);
y3 = 50 + 2*randn(1, l);
z3 = -l:-1;

% Create the data matrix in this way
A = [x1 x2 x3];
B = [y1 y2 y3];
C = [z1 z2 z3];
X = [A; B; C];

% Create class ID, indexing from zero
y = [1*ones(1, l), 2*ones(1, l), 3*ones(1, l)];

% How many dimensions
c = 2;

% Plot original data
close all
scatter3(x1, y1, z1, 'r')
hold on
scatter3(x2, y2, z2, 'b')
hold on
scatter3(x3, y3, z3, 'g')
title('Original 3D data', 'FontSize', 20)
legend('Class 1', 'Class 2', 'Class 3')

% Do LDA for 2D
[P, W] = mi.lda(X, y, c);

% Plot 2D were P is a c x l matrix
figure
scatter(P(1, 1:l), P(2,1:l), 'r')
hold on
scatter(P(1,l+1:2*l), P(2, l+1:2*l), 'b')
hold on
scatter(P(1, 2*l+1:3*l), P(2, 2*l+1:3*l), 'g')
grid on
title('Dimension reduction 2D data', 'FontSize', 20)
legend('Class 1', 'Class 2', 'Class 3')

% How many dimensions
c = 1;

% Do LDA for 1D
[P, W] = mi.lda(X, y, c);

% Plot 1D were P is a c x l matrix
figure
scatter(P(1, 1:l), 0*P(1, 1:l), 'r')
hold on
scatter(P(1, l+1:2*l), 0*P(1, l+1:2*l), 'b')
hold on
scatter(P(1, 2*l+1:3*l), 0*P(1, 2*l+1:3*l), 'g')
grid on
title('Dimension reduction 1D data', 'FontSize', 20)
legend('Class 1', 'Class 2', 'Class 3')
