% Sparse Identification of Nonlinear Dynamics
% Input: inputs, output, degree(How big the model should be), lambda(Tuning parameter), sampleTime
% Example: [dx] = mi.sindy(inputs, outputs, degree, lambda, sampleTime);
% Author: Daniel Mårtensson, May 2, 2020
% Update: Added more error handling and now display which activation function that being used, June 25, 2020
% Update: Easier to use 2023-05-18. Only change the degree input

function [dx] = sindy(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get inputs
  if(length(varargin) >= 1)
    inputs = varargin{1};
  else
    error('Missing inputs')
  end

  % Get outputs
  if(length(varargin) >= 2)
    outputs = varargin{2};
  else
    error('Missing outputs')
  end

  % Get degree
  if(length(varargin) >= 3)
    degree = varargin{3};
  else
    error('Missing degree')
  end

  % Get lambda
  if(length(varargin) >= 4)
    lambda = varargin{4};
  else
    error('Missing lambda')
  end

  % Get sampleTime
  if(length(varargin) >= 5)
    sampleTime = varargin{5};
  else
    error('Missing sample time')
  end

  % Find the derivative of outputs
  diff = outputs(2:end, :)-outputs(1:end-1, :);
  dX = diff/sampleTime;

  % Same length as dX
  outputs = outputs(1:end-1, :);
  inputs = inputs(1:end-1, :);

  % Do error checking between outputs and inputs
  if(size(outputs, 2) ~= size(inputs, 2))
    error('States and inputs need to have the same length of columns')
  end

  % Do error checking between dX and inputs
  if(size(dX, 1) ~= size(inputs, 1))
    error('Derivatives and inputs need to have the same length')
  end

  % Do error checking between outputs and inputs
  if(size(outputs, 1) ~= size(inputs, 1))
    error('Outputs and inputs need to have the same length')
  end

  % Create labels
  labels = [""];

  % Create the model dX = X*E
  m = size(inputs, 1);
  n = size(inputs, 2);

  % For the base e.g 1
  X = ones(m, 1);
  labels = [labels; "1"];

  % For polynomial e.g u^3 x^3
  for j = 1:n
    for i = 1:degree
      X = [X inputs.^i outputs.^i];
      if(i == 1)
        labels = [labels; 'u(', num2str(j), ')'; 'x(', num2str(j), ')'];
      else
        labels = [labels; 'u(', num2str(j), ')^', num2str(i); 'x(', num2str(j), ')^', num2str(i)];
      end
    end
  end

  % For multiplication u^3*x^3
  for j = 1:n
    for i = 1:degree
      X = [X inputs.^i.*outputs.^i];
      if(i == 1)
        labels = [labels; 'u(', num2str(j), ')*x(', num2str(j), ')'];
      else
        labels = [labels; 'u(', num2str(j), ')^', num2str(i), '*x(', num2str(j), ')^', num2str(i)];
      end
    end
  end

  % Optimize to find the weights
  E = stls_regression(X, dX, lambda);

  % Create function handler. Don't replace " with '. They have a pourpose.
  handler = "@(t, x, u)";
  equations = "";
  for i = 1:size(E, 2)
    % This is for so we don't write + directly after dy =
    firstTimeWriting = 1;
    % Save the equations here
    equation = [];
    % This is the right side of the equation
    for j = 1:size(labels, 1)
      % Only select values that have been sorted out by lambda value
      if(E(j, i) ~= 0)
        if(and(E(j, i) > 0, firstTimeWriting == 0))
          val = sprintf(" + %f", E(j, i));
        elseif(and(E(j, i) < 0, firstTimeWriting == 0))
          val = sprintf(" - %f", abs(E(j, i)));
        else
          if(E(j, i) > 0)
            val = sprintf(" %f", E(j, i));
          else
            val = sprintf(" -%f", abs(E(j, i)));
          end
        end
        firstTimeWriting = 0;
        equation = strcat(equation, val, '*', labels(j, :));
      end
    end
    % Add ; if i is below size of E
    if(i < size(E, 2))
      equation = strcat(equation, ';');
    end
    % Add equation to equations
    equations = [equations equation];
  end

  % Create the nonlinear model
  dx = str2func(strcat(handler, '[', equations , ']'));
end

function E = stls_regression(X, dX, lambda)

  % Initial guess
  E = linsolve(X, dX);
  state_dimension = size(dX, 2);

  % lambda is our sparsification knob.
  for k=1:10
      smallinds = (abs(E)<lambda);      % Find small coefficients
      E(smallinds) = 0;                 % Turn small numbers into zeros
      for ind = 1:state_dimension         % For every state dimension
        biginds = ~smallinds(:,ind);
        E(biginds,ind) = linsolve(X(:,biginds),dX(:,ind)); % Regress dynamics onto remaining terms to find sparse E
      end
  end
end
