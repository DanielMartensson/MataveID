close all
clear all

% Give the if-statement true and very nonlinar data is used, else, Fisher's Iris flower set is used
if(true)
  % Amount of rows
  numRows = 150;

  % Total Columns
  numColumns = 2;

  % Create a matrix of zeros for X and a vector of zeros for y
  X = zeros(numRows, numColumns);
  y = zeros(numRows, 1);

  % Create data for class 1 (non-linear function + noise)
  class1_x1 = 2 * rand(numRows/2, 1);  % Noise function
  class1_x2 = sin(class1_x1) + 0.2 * randn(numRows/2, 1);  % Nonlinear function with noise
  class1 = [class1_x1, class1_x2];
  y(1:numRows/2) = 1;  % Labels for class 1

  % Create data for class 2 (non-linear function + noise)
  class2_x1 = 2 * rand(numRows/2, 1) + 1;  % Noise
  class2_x2 = cos(class2_x1) + 0.2 * randn(numRows/2, 1);  % Nonlinear function with noise
  class2 = [class2_x1, class2_x2];
  y(numRows/2 + 1:end) = -1;  % Labels for class 2

  % Combine the data to create the final matrix X
  X(1:numRows/2, :) = class1;
  X(numRows/2 + 1:end, :) = class2;

  % Plot
  scatter(X(y == -1, 1), X(y == -1, 2));
  hold on
  scatter(X(y == 1, 1), X(y == 1, 2));
else
  % Load the Fisher's Iris data set
  data = load('fisheriris.mat');
  X = data.meas;
  y = strcmp(data.species,'setosa') * 2 - 1;
end

% Important to do shuffle!
s = randperm(150, 150)';
X = X(s, :);
y = y(s);

% Create train and test data
X_train = X(1:50, :);
y_train = y(1:50);
X_test = X(101:end, :);
y_test = y(101:end);

% Adaboost classification with N weak classifiers
N = 3;
[models, accuracy, activation_function] = mi.adaboost(X_train, X_test, y_train, y_test, N);

% This is how the class id is found from one randomly selected row from X_test
class_id = activation_function(models, X_test(5, :))
fprintf('Accuracy AdaBoost: %.2f%%\n', accuracy * 100);

% Compare the accuracy with the neural networks Neural network - One layer
C = 1;
lambda = 1;
X_train = X([1:20 51:70 101:120], :);
y_train = y([1:20 51:70 101:120]);
X_test = X([21:50 71:100 121:150], :);
y_test = y([21:50 71:100 121:150]);
[weight, bias, activation_function] = mi.nn(X_train, y_train, C, lambda);

% Validate
class_ids = sign(X_test*weight' + bias);
accuracy = sum(y_test == class_ids) / length(y_test);
fprintf('Accuracy Neural Network: %.2f%%\n', accuracy * 100);
