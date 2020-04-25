% nnlsim is a function to simulate nonlinear state space models.
% Input: nlsys, u, t, x0(optional)
% Example 1: [y,t,X] = nnlsim(nlsys, u, t, x0);
% Example 1: [y,t,X] = nnlsim(nlsys, u, t);
% Author: Daniel Mårtensson, June 2018

function [y,t,X] = nnlsim (varargin)
  MAXvector = 1000; % Maximum dimension of state vector and input vector
  
  % Check if there is some input arguments or it's not a model
  if(isempty(varargin{1}))
    error ('Missing model')
  end

  if(strcmp(varargin{1}.type,'NLSS'))
    % Get A, B, C, D and delay
    model = varargin{1};
    A = model.A;
    B = model.B;
    C = model.C; % Will not be used
    D = model.D; % Will not be used
    
    % Get input
    u = varargin{2}; % In signal vector
    % Check in signal vector
    if(size(u, 1) ~= size(B(1:MAXvector, 1:MAXvector),2))
      error('In signal vecor has not the same columns as B matrix')
    end
    
    % Get time
    tspan = varargin{3}; 
    % Check t vector
    if(size(tspan, 1) > 1)
      error('No double time vector are allowed')
    end
    
    % Check if t and u have the same length
    lengthTime = length(tspan);
    lengthSignal = length(u);
    if(lengthTime ~= lengthSignal)
      error('Input and time has not the same length')
    end
    
    
    % Get the initial state vector
    if(length(varargin) >= 4)
      x0 = varargin{4}(:); % Initial state vector
      if(size(x0, 1) ~= size(A(1:MAXvector, 1:MAXvector),1))
        error('Initial state vector vecor has not the same rows as A matrix')
      end
    else
      % Does not exist - create one then!
      x0 = zeros(size(A(1:MAXvector, 1:MAXvector),1), 1); % Assume x0 = [0; 0; 0; ..... ; 0]
    end
    
    % Use ODE45 - Stable ODE solver. Nonlinear systems can be very unstable in simulations
    [t, x] = ode45(@(t, x) f(t, x, u, tspan, A, B),tspan, x0);
    
    % Do the same, but find the output signal
    for j = 1:length(t)
      % This is used beacuse interp1 cannot hold a higher dimension > 1 of u
      for i = 1:size(u, 1)
        U(i, :) = interp1(tspan, u(i, :), t(j));
      end
      
      % Get the output signal now.
      y(:, j) = sum(C(x(j, :), U)', 1)' + sum(D(x(j, :), U)', 1)';
    end
    
    
    % Plot output - How many subplots?
    for i = 1:size(C(1:MAXvector, 1:MAXvector),1)
      subplot(size(C(1:MAXvector, 1:MAXvector),1),1,i)
      plot(t, y(i,:)); 
      ylabel(strcat('y', num2str(i)));
      xlabel('Time units');
      grid on
    end
    
  end
end

function [dx] = f(t, x, u, tspan, A, B)

  % This is used beacuse interp1 cannot hold a higher dimension > 1 of u
  for i = 1:size(u, 1)
    U(i, :) = interp1(tspan, u(i, :), t);
  end
  
  dx = sum(A(x, U)', 1)' + sum(B(x, U)', 1)'; % The state space model 
end
