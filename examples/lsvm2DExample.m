% Data
X = [5 3;
     2 1;
     7 2;
     8 3;
     9 1;
     15 23;
     17 18;
     18 13;
     16 20;
     19, 15];

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
% Plot 2D
scatter(X(y == -1,1),X(y == -1,2), 'r');
hold on
scatter(X(y == 1,1), X(y == 1,2), 'g');
grid on
legend('Class A', 'Class B', 'location', 'northwest')
     
% Tuning parameters
C = 1; % For upper boundary limit
lambda = 1; % Regularization (Makes it faster to solve the quadratic programming)

% Compute weigths, bias and find accuracy
[w, b, accuracy, solution] = lsvm(X, y, C, lambda);

% How long the line should be
min_value_column_1 = min(X(:,1));
max_value_column_1 = max(X(:,1));

% Create the separation line y = k*x + m
x1 = linspace(min_value_column_1, max_value_column_1);
x2 = (-w(1)*x1 - b) / w(2);

% Plot the separation line
plot(x1, x2, 'k', 'LineWidth', 2);
xlim([0 20]) % Max x-axis limit
ylim([0 20]) % Max y-axis limit
legend('Class A', 'Class B', 'Separation', 'location', 'northwest')
     
% Classify
x_unknown = [15; 5];
class_ID = sign(w*x_unknown - b)
if(class_ID > 0)
  disp('x_unknown class A')
else
  disp('x_unknown is class B')
end
