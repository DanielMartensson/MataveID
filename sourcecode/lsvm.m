% Linear Support Vector Machine
% Input: x(Data matrix), y(Labels), C(Upper bondary), lambda(Regularization)
% Output: w(Model weights), b(Model bias), accuracy(Of the model), solution(If the solution was found)
% Example: [w, b, accuracy, solution] = lsvm(x, y, C, lambda);
% Author: Daniel Mårtensson, May 06, 2023
% To verify the model, just use:
% class_ID = sign(w*x + b), where x is an unknown measurement vector

function [w, b, accuracy, solution] = lsvm(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get data X
  if(length(varargin) >= 1)
    x = varargin{1};
  else
    error('Missing data x')
  end

  % Get labels y
  if(length(varargin) >= 2)
    y = varargin{2};
  else
    error('Missing labels y')
  end

  % Get C
  if(length(varargin) >= 3)
    C = varargin{3};
    if(C < 0 )
      C = eps;
    end
  else
    error('Missing C')
  end

  % Get lambda
  if(length(varargin) >= 4)
    lambda = varargin{4};
  else
    error('Missing lambda')
  end

  % Compute rows and columns
  [m, n] = size(x);

  % Train Support Vector Machine
  Q = (y*y').*(x*x');
  Q = Q + lambda*eye(size(Q));
  c = -ones(size(y));
  Aeq = y';
  beq = 0;
  lb = zeros(size(y));
  ub = C*ones(size(y));
  G = [eye(size(Q)); -eye(size(Q)); Aeq; -Aeq];
  h = [ub; -lb; beq; -beq];
  [alpha, solution] = quadprog(Q, c, G, h);

  % Support vectors have non zero lagrange multipliers
  tol = 1e-5;
  sv_idx = find(alpha > tol);

  % Find weights and bias
  w = (alpha(sv_idx).* y(sv_idx))' * x(sv_idx, :);
  b = mean(y(sv_idx)-x(sv_idx,:)*w');

  % Check if the training result well
  counter = 0;
  for i = 1:m
    % Predict
    predicted_class_ID = sign(w*x(i, :)' - b);
    actual_class_ID = y(i);

    % Count if the prediction is right
    if(or(and(actual_class_ID > 0, predicted_class_ID > 0), and(actual_class_ID < 0, predicted_class_ID < 0)))
      counter = counter + 1;
    end

  end

  % Compute accuracy
  accuracy = counter/m;
end
