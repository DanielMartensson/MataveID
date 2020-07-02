% Sparse Identification of Nonlinear Dynamics
% Activations for u and y: 1, u, y, u^2, y^2, u^3, y^3, u*y, sin(u), sin(y), cos(u), cos(y), tan(u), tan(y), sqrt(u), sqrt(y)
% Input: inputs, states, derivatives, activations, lambda
% Example: sindyc(inputs, states, derivatives, activations, variables, lambda);
% Author: Daniel Mårtensson, May 2, 2020
% Update: Added more error handling and now display which activation function that being used, June 25, 2020

function sindy(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
  end
  
  % Get inputs
  if(length(varargin) >= 1)
    inputs = varargin{1};
  else
    error('Missing inputs')
  end
  
  % Get states
  if(length(varargin) >= 2)
    states = varargin{2};
  else
    error('Missing states')
  end
  
  % Get derivatives
  if(length(varargin) >= 3)
    derivatives = varargin{3};
  else
    error('Missing derivatives')
  end
  
  % Get activations
  if(length(varargin) >= 4)
    activations = varargin{4};
  else
    error('Missing activations')
  end
  
  % Get variables
  if(length(varargin) >= 5)
    variables = cellstr(varargin{5});
  else
    error('Missing variable vector')
  end
  
  % Get lambda
  if(length(varargin) >= 6)
    lambda = varargin{6};
  else
    error('Missing lambda')
  end
  
  % Do error checking between states and inputs
  if(length(states) ~= length(inputs))
    error('States and inputs need to have the same length')
  end
  
  % Do error checking between derivatives and inputs
  if(length(derivatives) ~= length(inputs))
    error('Derivatives and inputs need to have the same length')
  end
  
  % Create our data, it must contain states and inputs. States can be interpreted as outputs by the way!
  data = [states; inputs];
  
  % Create our O matrix - Our system matrix. Here we create our data by the candidate functions
  l = size(data, 1);
  labels = [""]; % String array - Important so we can see which candidate we have selected
  O = zeros(length(data), 1);
  columnposition = 2; % We start at 2 due to the first column is constant 1
  O(:, 1) = 1; % Add ones only as constants
  labels = [labels; "1"];
  [O, columnposition, labels] = candidate(O, data, l, columnposition, variables, labels, "none"); % We add every inputs
  [O, columnposition, labels] = candidate(O, data.^2, l, columnposition, variables, labels, "^2"); % We use the raised to power 2 candidate
  [O, columnposition, labels] = candidate(O, data.^3, l, columnposition, variables, labels, "^3"); % We use the raised to power 3 candidate
  [O, columnposition, labels] = candidatexyz(O, data, l, columnposition, variables, labels, "*"); % We add e.g x.*y, z.*u, y.*u
  [O, columnposition, labels] = candidate(O, sin(data), l, columnposition, variables, labels, "sin"); % We use the add sin candidate
  [O, columnposition, labels] = candidate(O, cos(data), l, columnposition, variables, labels, "cos"); % We use the add cos candidate
  [O, columnposition, labels] = candidate(O, tan(data), l, columnposition, variables, labels, "tan"); % We use the add tan candidate
  [O, columnposition, labels] = candidate(O, sqrt(data), l, columnposition, variables, labels, "sqrt"); % We use the add sqrt candidate
  % You can add more candidates here!
  
  % Cut O matrix so we only using the selected candidates
  lengthActivations = length(activations);
  lengthO = size(O, 2);
  if(lengthActivations ~= lengthO)
    error(strcat('Try to have activations as [', num2str(ones(1, lengthO)), '] to begin with'));
  end
  O = O(:, 1:lengthActivations); 
  
  % Delete all zero columns when we activate the candidates - Now we only using selected candidates
  O = O.*activations;
  O( :, ~any(O,1) ) = [];
  
  % Print candidates that we are using
  text = strcat('Candidates we are using with selected activations for:', '[', num2str(activations), ']');
  disp(text);
  used_labels = [""];
  for j = 1:length(activations)
    if(activations(j) ~= 0)
      used_labels = [used_labels; labels(j, :)]; % Save them for the last for-loop
    end
    disp(strcat(num2str(activations(j)), ':', labels(j, :))) % Show enabled and disabled
  end
  
  % Do least squares for every column of derivatives - This is the heart of SINDyC
  state_dimension = size(O, 2);
  E = stls_regression(O, derivatives, lambda);
  
  % Print E - Don't replace " with '. They have a pourpose.
  text = "\nOur nonlinear state space model:";
  disp(text);
  for i = 1:size(E, 2)
    % This is for so we don't write + directly after dy = 
    firstTimeWriting = 1;
    % This is the left side of the equation
    derivative = strcat('d', cell2mat(variables(i, :)), ' = '); % Get the e.g 'dx =' or 'dy ='
    % This is the annonymous function handler
    handler = " @(";
    for k = 1:size(variables, 1)
      if(k < size(variables, 1))
        handler = strcat(handler, cell2mat(variables(k, :)), ",");
      else
        handler = strcat(handler, cell2mat(variables(k, :)), ") ");
      end
    end
    % Save the equations here
    equation = [];
    % This is the right side of the equation
    for j = 1:size(used_labels, 1)
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
            val = sprintf(" - %f", abs(E(j, i)));
          end
        end
        firstTimeWriting = 0;
        equation = strcat(equation, val, '*', used_labels(j, :));  
      end
    end  
    strcat(derivative, handler, equation) % Print the equation for every i - row
  end
end

function dXi = stls_regression(O, dX, lambda)

  % Initial guess
  dXi = linsolve(O, dX);
  state_dimension = size(dX, 2);

  % lambda is our sparsification knob.
  for k=1:10
      smallinds = (abs(dXi)<lambda);      % Find small coefficients
      dXi(smallinds) = 0;                 % Turn small numbers into zeros
      for ind = 1:state_dimension         % For every state dimension
        biginds = ~smallinds(:,ind);
        dXi(biginds,ind) = linsolve(O(:,biginds),dX(:,ind)); % Regress dynamics onto remaining terms to find sparse Xi
      end
  end
end

% This add its candidates
function [O, columnposition, labels] = candidate(O, data, l, columnposition, variables, labels, func)
  for i = 1:l
    
    % Add the name of the label
    switch func
      case 'none'
        labels = [labels; cell2mat(variables(i, :))]; % Regular
      case '^2'
        labels = [labels; strcat(cell2mat(variables(i, :)), '^2')]; % e.g x^2
      case '^3'
        labels = [labels; strcat(cell2mat(variables(i, :)), '^3')]; % e.g x^3
      case 'sin'
        labels = [labels; strcat('sin(', cell2mat(variables(i, :)), ')')]; % e.g sin(x)
      case 'cos'
        labels = [labels; strcat('cos(', cell2mat(variables(i, :)), ')')];
      case 'tan'
        labels = [labels; strcat('tan(', cell2mat(variables(i, :)), ')')];
      case 'sqrt'
        labels = [labels; strcat('sqrt(', cell2mat(variables(i, :)), ')')];
      % Add more here such as e^x or sin(x*y) etc.
    end
    
    % Add to O matrix
    O(:, columnposition) = data(i,:);
    columnposition = columnposition + 1;
  end 
end

% This add candidates with multiplication about each other
function [O, columnposition, labels] = candidatexyz(O, data, l, columnposition, variables, labels, func)
  for j = 1:l
    for i = 1:l
      if(j ~= i)
      
        % Add the name of the label
        switch func
          case '*'
          labels = [labels; strcat(cell2mat(variables(j, :)), '*', cell2mat(variables(i, :)))]; % e.g x*y
        end
        
        % Add to O matrix
        O(:, columnposition) = data(j,:).*data(i,:); % e.g x.*y, y.*z, z.*k, k.*j, j.*i where inputs is [x;y;z,k,j,i] and l is 6 due to row size of [x;y;z,k,j,i]
        columnposition = columnposition + 1;
      end
    end
  end 
end
