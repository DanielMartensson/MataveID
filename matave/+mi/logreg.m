% Curve fit data onto a logaritmic function
% Input: x(Input data vector), y(Label vector), function_type('sigmoid', 'tanh')
% Output: a(parameter), b(parameter)
% Function types:
% Sigmoid: p(x) = 1/(1 + e^(-a*x - b))
% Tanh: p(x) = (e^(a*x + b) - e^(-a*x - b))/(e^(a*x + b) + e^(-a*x - b))
% Example 1: [a, b, flag, iterations] = mi.logreg(x, y, function_type);
% Author: Daniel Mårtensson, Augusti 2023

function [a, b, flag, iterations] = logreg(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing inputs')
  end

  % Get data
  if(length(varargin) >= 1)
    x = varargin{1};
  else
    error('Missing input data x')
  end

  % Get labels
  if(length(varargin) >= 2)
    y = varargin{2};
  else
    error('Missing labels')
  end

  % Get function type
  if(length(varargin) >= 3)
    function_type = varargin{3};
  else
    error('Missing function type')
  end

  % Check length
  n = length(x);
  if(n ~= length(y))
    disp('Labels and input data must have the same length');
  end

  % Create function type
  switch(function_type)
  case 'sigmoid'
    reg_function = @(parameters) 1./(1 + exp(-parameters(1)*x - parameters(2)));
    loss_function = @(parameters) 1/n*sum(abs(reg_function(parameters) - (y == 1)));
  case 'tanh'
    reg_function = @(parameters) (exp(parameters(1)*x + parameters(2)) - exp(-parameters(1)*x - parameters(2)))./(exp(parameters(1)*x + parameters(2)) + exp(-parameters(1)*x - parameters(2)));
    loss_function = @(parameters) 1/n*sum(abs(reg_function(parameters) - y));
  end

  % Optimize and find the parameters a and a
  x0 = [0; 0];
  [parameters, ~, flag, iterations]  = mc.fminsearch(loss_function, x0);
  a = parameters(1);
  b = parameters(2);
end
