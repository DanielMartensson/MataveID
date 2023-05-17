clc; clear; close all;

% How much data should we generate 
N = 50;

% How many classes 
c = 5;

% Create variance and average for X and Y data
X_variance = [2, 4, 3, 4, 5];
Y_variance = [3, 5, 3, 4, 5];
X_average = [50, 70, 10, 90, 20];
Y_average = [20, 70, 60, 10, 20];

% Create scatter data
X = zeros(c, N);
Y = zeros(c, N);
for i = 1:c
  % Create data for X-axis 
  X(i, 1:N) = X_average(i) + X_variance(i)*randn(1, N);
    
  % Create data for Y-axis
  Y(i, 1:N) = Y_average(i) + Y_variance(i)*randn(1, N);
end
  
% Create SVM model - X_point and Y_point is coordinates for the Nonlinear SVM points.
% amount_of_supports_for_class is how many points there are in each row
[X_point, Y_point, amount_of_supports_for_class] = mi.nlsvm(X, Y);
  
% Do a quick re-sampling of random data again
for i = 1:c
  % Create data for X-axis 
  X(i, 1:N) = X_average(i) + X_variance(i)*randn(1, N);
    
  % Create data for Y-axis
  Y(i, 1:N) = Y_average(i) + Y_variance(i)*randn(1, N);
end
  
% Check the SVM model
point_counter_list = zeros(1, c);
for i = 1:c
  % Get the points 
  svm_points_X = X_point(i, 1:amount_of_supports_for_class(i));
  svm_points_Y = Y_point(i, 1:amount_of_supports_for_class(i));
    
  % Count how many data points this got - Use inpolygon function that return 1 or 0 back
  point_counter_list(i) = sum(inpolygon(X(i,:) , Y(i, :), svm_points_X, svm_points_Y));
end
  
% Plot how many each class got - Maximum N points per each class
figure 
bar(point_counter_list);
xlabel('Class index');
ylabel('Points');
