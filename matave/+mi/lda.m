% Linear Discriminant Analysis
% Input: X(Data), y(Class ID), c(Amount of components)
% Output: Projected matrix P, Project matrix W
% Example 1: [P, W] = mi.lda(X, y, c);
% Author: Daniel Mårtensson, 2023 April

function [P,W] = lda(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get impulse response
  if(length(varargin) >= 1)
    X = varargin{1};
  else
    error('Missing data X')
  end

  % Get the sample time
  if(length(varargin) >= 2)
    y = varargin{2};
  else
    error('Missing class ID y');
  end

  % Get the sample time
  if(length(varargin) >= 3)
    c = varargin{3};
  else
    error('Missing amount of components');
  end

  % Get size of X
  [row, column] = size(X);

  % Create average vector mu_X = mean(X, 2)
  mu_X = mean(X, 2);

  % Count classes
  amount_of_classes = max(y);

  % Create scatter matrices Sw and Sb
  Sw = zeros(row, row);
  Sb = zeros(row, row);

  % How many samples of each class
  samples_of_each_class = zeros(1, amount_of_classes);
  for i = 1:column
    samples_of_each_class(y(i)) = samples_of_each_class(y(i)) + 1;
  end

  % Iterate all classes
  shift = 1;
  for i = 1:amount_of_classes
    % Get samples of each class
    samples_of_class = samples_of_each_class(i);

    % Copy a class to Xi from X
    Xi = X(:, shift:shift+samples_of_class - 1);

    % Shift
    shift = shift + samples_of_class;

    % Get average of Xi
    mu_Xi = mean(Xi, 2);

    % Center Xi
    Xi = Xi - mu_Xi;

    % Copy Xi and transpose Xi to XiT and turn XiT into transpose
    XiT = Xi';

    % Create XiXiT = Xi*Xi'
    XiXiT = Xi*XiT;

    % Add to Sw scatter matrix
    Sw = Sw + XiXiT;

    % Calculate difference
    diff = mu_Xi - mu_X;

    % Borrow this matrix and do XiXiT = diff*diff'
    XiXiT = diff*diff';

    % Add to Sb scatter matrix - Important to multiply XiXiT with samples of class
    Sb = Sb + XiXiT*samples_of_class;
  end

  % Do eigendecomposition
  [V, D] = eig(Sb, Sw);

  % Compute the rank
  fprintf('An optimal dimension reduction parameter for KPCA is cpca -> %i\n', rank(Sw));

  % Sort eigenvectors descending by eigenvalue
  [D, idx] = sort(diag(D), 1, 'descend');
  V = V(:,idx);

  % Get components W
  W = V(:, 1:c);
  P = W'*X;
end
