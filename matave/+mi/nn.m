% Create a neural network by using Support Vector Machine
% The activation function is: y = @(x) find(x == max(x)), where x is a vector
% Input: data(Train data), class_id(Class ID vector of every row of train data), C(C-parameter for SVM), lambda(Regulariztion for SVM)
% Output: weight, bias
% Example 1: [weight, bias, activation_function] = mi.nn(data, class_id)
% Example 2: [weight, bias, activation_function] = mi.nn(data, class_id, C)
% Example 3: [weight, bias, activation_function] = mi.nn(data, class_id, C, lambda)
% Example 4: [weight, bias, activation_function] = mi.nn(data, class_id, C, lambda)
% Author: Daniel Mårtensson, Augusti 2023

function [weight, bias, activation_function] = nn(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get train data
  if(length(varargin) >= 1)
    data = varargin{1};
  else
    error('Missing train data')
  end

  % Get class ID
  if(length(varargin) >= 2)
    class_id = varargin{2};
  else
    error('Missing class ID vector')
  end

  % Get C for SVM
  if(length(varargin) >= 3)
    C = varargin{3};
  else
    C = 1;
  end

  % Get lambda regularization
  if(length(varargin) >= 4)
    lambda = varargin{4};
  else
    lambda = 1;
  end

  % Get function type
  if(length(varargin) >= 5)
    function_type = varargin{5};
  else
    function_type = 'tanh';
  end

  % Create the y vector
  classes = max(class_id);

  % Find the size of data
  [m, n] = size(data);

  % Create model
  weight = [];
  bias = [];

  % Create one SVM model per class
  for i = 1:classes
    % Create a -1 labels array
    labels = linspace(-1, -1, m)';

    % Fill y with 1 for a specific class
    index = find(i == class_id);
    labels(index) = 1;

    % Do linear SVM
    [w, b, accuracy, solution] = mi.lsvm(data, labels, C, lambda);

    % Status
    if(solution)
      fprintf('Training: Neural Network success with accuracy: %f at class: %i\n', accuracy, i);
    else
      fprintf('Training: Neural Network failed with accuracy: %f at class: %i\n', accuracy, i);
    end

    % Save model
    weight = [weight; w];
    bias = [bias; b];
  end

  % Create the activation function where x is a vector. This gives the row index of maximum value of x, which is the class ID
  activation_function = @(x) find(x == max(x));
end
