% Linear Support Vector Machine
% Input: x(Data matrix), y(Labels), C(Upper bondary), lambda(Regularization)
% Example: [w, b, accuracy] = lsvm(x, y, C, lambda);
% Author: Daniel Mårtensson, May 06, 2023

function [w, b, accuracy] = lsvm(varargin)
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
  H = (y*y').*(x*x');
  H = H + lambda*eye(size(H));
  f = -ones(size(y));
  Aeq = y';
  beq = 0;
  lb = zeros(size(y));
  ub = C*ones(size(y));
  [alpha, solution] = quadprog(H, f, [eye(size(H)); -eye(size(H)); Aeq; -Aeq], [ub; -lb; beq; -beq]);

  % Find weights
  w = (alpha.* y)' * x;

  % Support vectors have non zero lagrange multipliers
  tol = 1.192092896e-07;
  sv_idx = find(alpha > tol);
  b = mean(y(sv_idx)-x(sv_idx,:)*w');

  % Check if the training result well
  points = 0;
  for i = 1:m
    % Predict
    predicted_class_ID = sign(w*x(i, :)' + b);
    actual_class_ID = y(i);

    % Count if the prediction is right
    if(or(and(actual_class_ID > 0, predicted_class_ID > 0), and(actual_class_ID < 0, predicted_class_ID < 0)))
      points = points + 1;
    end

  end

  % Compute accuracy
  accuracy = points/m;
  printf("The accuracy of the model is: %f\n", accuracy);
end
