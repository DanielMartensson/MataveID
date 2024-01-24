% Adaptive Boosting with Decision Stumps. The reason why to use AdaBoost is that it's has a very quick prediction time, compared to SVM or Neural Networks.
% Input: X_train(Data), X_test(Data), y_train(Labels), y_test(Labels), N(Model size)
% Output: models, accuracy, activation_function
% Example 1: [models, accuracy, activation_function] = mi.adaboost(X_train, X_test, y_train, y_test, N);
% Author: Daniel Mårtensson, 2024 Januari

function [models, accuracy, activation_function] = adaboost(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get the train data
  if(length(varargin) >= 1)
    X_train = varargin{1};
  else
    error('Missing train data')
  end

  % Get the test data
  if(length(varargin) >= 2)
    X_test = varargin{2};
  else
    error('Missing test data')
  end

  % Get the train labels
  if(length(varargin) >= 3)
    y_train = varargin{3};
  else
    error('Missing train labels y')
  end

  % Get the test labels
  if(length(varargin) >= 4)
    y_test = varargin{4};
  else
    error('Missing test labels y')
  end

  % Get the amount of models
  if(length(varargin) >= 5)
    N = varargin{5};
  else
    N = size(X_train, 2);
  end

  % Fit a model
  models = train(X_train, y_train, N);

  % Do evaluation
  accuracy = evaluate(models, X_test, y_test, N);

  % Create prediction function
  activation_function = @prediction_function;
end

function models = train(X, y, N)
  % Get the size of the data
  [m, n] = size(X);

  % Initialize weights to 1/N
  w = ones(m, 1) / m;

  % Create model struct
  models = {};

  % Iterate through classifiers
  for i = 1:N
    % Create the model with initial parameters
    model.polarity = 0;
    model.feature_index = 0;
    model.threshold = 0;
    model.alpha = 0;

    % Initial error
    min_error = inf;

    % Iterate throught every unique feature value and see what value
    for j = 1:n
      % Get one column
      feature_column = X(:, j);

      % Sort the columns so only unique values are with the training
      unique_values = unique(feature_column);

      for threshold = unique_values'
        % Set the initital polarty
        p = 1;

        % Set all predictions to '1' initially
        predictions = ones(size(y));

        % Label the samples whose values are below threshold as '-1'
        predictions(feature_column < threshold) = -1;

        % Error = sum of weights of misclassified samples
        error = sum(w(y ~= predictions));

        % If the error is over 50% we flip the polarity so that samples that
        % were classified as 0 are classified as 1, and vice versa
        % E.g error = 0.8 => (1 - error) = 0.2
        if error > 0.5
          error = 1 - error;
          p = -1;
        end

        % If this threshold resulted in the smallest error we save the configuration
        if error < min_error
          model.polarity = p;
          model.threshold = threshold;
          model.feature_index = j;
          min_error = error;
        end
      end
    end

    % Calculate the alpha which is used to update the sample weights. Alpha is also an approximation of this classifier's proficiency
    model.alpha = 0.5 * log((1.0 - min_error) / (min_error + 1e-10));

    % Set all predictions to '1' initially
    predictions = ones(size(y));

    % The indexes where the sample values are below threshold
    negative_idx = (model.polarity * X(:, model.feature_index) < model.polarity * model.threshold);

    % Label those as '-1'
    predictions(negative_idx) = -1;

    % Missclassified samples gets larger weights and correctly classified samples smaller
    w = w .* exp(-model.alpha * y .* predictions);

    % Normalize to one
    w = w / sum(w);

    % Save the model
    models{i} = model;
  end
end

function accuracy = evaluate(models, X, y, N)
  % Find the row size
  m = size(X, 1);

  % Initial zeros
  y_pred = zeros(m, 1);

  % For each classifier => label the samples
  for i = 1:N
    % Get a model
    model = models{i};

    % Initial predictions
    predictions = ones(size(y_pred));

    % The indexes where the sample values are below threshold
    negative_idx = (model.polarity * X(:, model.feature_index) < model.polarity * model.threshold);

    % Label those as '-1'
    predictions(negative_idx) = -1;

    % Add predictions weighted by the classifiers alpha(alpha indicative of classifier's proficiency)
    y_pred = y_pred + model.alpha * predictions;
  end

  % Return sign of prediction sum
  y_pred = sign(y_pred);

  % Find the accuracy
  accuracy = sum(y == y_pred) / length(y);
end

function pred = prediction_function(models, x)
  % Iterate all models
  s = 0;
  for i = 1:length(models)
    % Initial prediction
    prediction = ones(1);

    negative_idx = (models{i}.polarity * x(models{i}.feature_index) < models{i}.polarity * models{i}.threshold);

    % Label those as '-1'
    prediction(negative_idx) = -1;

    s = s + models{i}.alpha * prediction;
  end

  % The final answer
  pred = sign(s);
end
