% Data
X = [5 3 2;
     2 1 3;
     7 2 4;
     8 3 1;
     9 1 2;
     15 23 23;
     17 18 13;
     18 13 63;
     16 20 24;
     19, 15 52];

% Labels of the data for each class
y = [1;
     1;
     1;
     1;
     1;
     -1;
     -1;
     -1;
     -1;
     -1];

% Plot 3D
scatter3(X(y == -1,1),X(y == -1,2), X(y == -1,3), 'r');
hold on
scatter3(X(y == 1,1), X(y == 1,2), X(y == 1,3), 'g');
grid on
legend('Class A', 'Class B', 'location', 'northwest')

% Tuning parameters
C = 1;              % For upper boundary limit
lambda = 1;         % Regularization (Makes it faster to solve the quadratic programming)

% Compute weigths, bias and find accuracy
[w, b, accuracy, solution] = lsvm(X, y, C, lambda);

% Definiera området för 3D-plot
x1Range = linspace(min(X(:,1))-1, max(X(:,1))+1, 50);
x2Range = linspace(min(X(:,2))-1, max(X(:,2))+1, 50);
[x1Grid, x2Grid] = meshgrid(x1Range, x2Range);
x3Grid = (-w(1)*x1Grid - w(2)*x2Grid - b) / w(3);

% Plot the hyperplane
surf(x1Grid, x2Grid, x3Grid, 'FaceAlpha', 0.5);
colormap(gray);
legend('Class A', 'Class B', 'Separation', 'location', 'northwest')

% Classify
x_unknown = [15; 5; 7];
class_ID = sign(w*x_unknown - b)
if(class_ID > 0)
  disp('x_unknown class A')
else
  disp('x_unknown is class B')
end
