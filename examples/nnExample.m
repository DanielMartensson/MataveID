% Clear
close all
clear all
clc

% Data - Avoid the header and the last column
data_raw = double(csvread('..','data','iris.csv')(2:end, 1:end-1));

% 3 class labels
class_id = [linspace(1, 1, 50)'; linspace(2, 2, 50)'; linspace(3, 3, 50)'];

% Create neural network
C = 2;
lambda = 0.5;
[weight, bias, activation_function] = mi.nn(data_raw, class_id, C, lambda);

% Check accuracy
X = weight*data_raw' + bias;
classes = length(class_id);
score = 0;
for i = 1:classes
  class_id_predicted = activation_function(X(:, i));
  if(class_id_predicted == class_id(i))
    score = score + 1;
  end
end

% Print status
fprintf('The accuracy of this model is: %i\n', score/classes*100);
