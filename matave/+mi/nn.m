% Create a neural network by using Support Vector Machine
% Input: data(Train data), class_id(Class ID vector of every row of train data), C(C-parameter for SVM), lambda(Regulariztion for SVM), function_type('sigmoid', 'tanh', 'ReLU', 'Leaky ReLU')
% Output: weight, bias, A(Prameter vector for activation function), B(Parameter vector for activation function)
% Example 1: [weight, bias, A, B] = mi.nn(data, class_id)
% Example 2: [weight, bias, A, B] = mi.nn(data, class_id, C)
% Example 3: [weight, bias, A, B] = mi.nn(data, class_id, C, lambda)
% Example 4: [weight, bias, A, B] = mi.nn(data, class_id, C, lambda, function_type)
% Author: Daniel Mårtensson, Augusti 2023

function [weight, bias, A, B] = nn(varargin)
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
    function_type = 'sigmoid';
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
        fprintf('Neural Network success with accuracy: %f at class: %i\n', accuracy, i);
    else
        fprintf('Neural Network failed with accuracy: %f at class: %i\n', accuracy, i);
    end

    % Save model
    weight = [weight; w];
    bias = [bias; b];
  end

  % Compute the scores and labels
  X = weight*data' + bias;
  Y = sign(X);

  % Create parameter for activation function
  A = zeros(classes, 1);
  B = zeros(classes, 1);

  % Create activation function parameters
  switch(function_type)
  case 'ReLU'
    B = ones(classes, 1);
  case 'Leaky ReLU'
    A = linspace(0.1, 0.1, classes)';
    B = ones(classes, 1);
  otherwise
    % Find parameters for logistic activation functions
    for i = 1:classes
      % Extract one row of the labels
      y = Y(i, :);
      x = X(i, :);

      % Find parameters
      [a, b, flag, iterations] = mi.logreg(x, y, function_type);

      % Save
      A(i) = a;
      B(i) = b;

      % Print status
      if(~flag)
        fprintf('Logistic regression output for neural network failed for class %i. Iterations(%i)\n', i, iterations);
      end
    end
  end
end
