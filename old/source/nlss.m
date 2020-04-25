% nlss is a function to create nonlinear state space models.
% All you need is to include a function handle A = @(x,u) and B = @(x,u), or C = @(x,u) or D = @(x,u)
% Input: A,B, C(optional), D(optional)
% Example 1: [sys] = nlss(A,B,C,D);
% Example 2: [sys] = nlss(A,B,C);
% Example 3: [sys] = nlss(A,B);
% Author: Daniel Mårtensson, June 2018

function [sys] = nlss(varargin)
  MAXvector = 1000; % Maximum dimension of state vector and input vector
  
  if(length(varargin) < 1)
    error('A-matrix and B-matrix')
  end
  
  if(length(varargin) < 2)
    error('B-matrix')
  else
    A = varargin{1};
    n = nargin(A);
    % Check if A has two input vectors x and u
    if n ~= 2
      error('A need to have the function handle @(x,u)');
    end
    
    % Check if sys.A is square matrix
    if(size(A(1:MAXvector, 1:MAXvector),1) ~= size(A(1:MAXvector, 1:MAXvector),2))
      error('A is not a square');
    end
  end
  
  if(length(varargin) < 2)
    error('Missing B-matrix')
  else
    B = varargin{2};
    m = nargin(B);
    
    % Check if B has two input vectors x and u
    if m ~= 2
      error('B need to have the function handle @(x,u)');
    end
    
    % Check if sys.A and sys.B have the same lenght of rows
    if(size(A(1:MAXvector, 1:MAXvector),1) ~= size(B(1:MAXvector, 1:MAXvector),1))
      error('A and B have not the same row length');
    end
  end
  
  if(length(varargin) < 3)
    sprintf('C matrix assumed to be a diagonal %ix%i matrix', size(A(1:MAXvector, 1:MAXvector),1), size(A(1:MAXvector, 1:MAXvector),2))
    
    A_colum_Dimension = size(A(1:MAXvector, 1:MAXvector),2); % Column dimension
    
    % Create a diagnoal C matrix
    DiagonalC = eye(A_colum_Dimension); % 
    Cstr = '[ ';
    for i = 1:A_colum_Dimension
      rowStringEyeMatrix = num2str(DiagonalC(i, :));
      % Replace
      newRowStringEyeMatrix = strrep(rowStringEyeMatrix, '1', strcat(sprintf('x(%i)', i)));
      Cstr = strcat(Cstr, newRowStringEyeMatrix, ';');
    end
    
    % Remove the last ';' and then add ']' 
    Cstr = Cstr(1:end-1);
    % Add ']' at the end
    Cstr = strcat(Cstr, ']');
    
    Hstr = '@(x,u)'; % Create the handle
    Cfun = strcat(Hstr, Cstr);
    
    % Creat the function
    C = str2func(Cfun);
    
  else
    C = varargin{3};
    % Check if sys.A and sys.C have the same lenght of columns
    q = nargin(C); 
    
    % Check if C has two input vectors x and u
    if q ~= 2
      error('C need to have the function handle @(x,u)');
    end
    
    if(size(A(1:MAXvector, 1:MAXvector),2) ~= size(C(1:MAXvector, 1:MAXvector),2))
      error('A and C have not the same column length');
    end
  end
  
  if(length(varargin) < 4)
    q = nargin(C); 
    sprintf('D matrix assumed to be a zero %ix%i matrix', size(C(1:MAXvector, 1:MAXvector),1), size(B(1:MAXvector, 1:MAXvector),2))
  
    B_colums_dimension = size(B(1:MAXvector, 1:MAXvector),2); 
    C_row_dimension = size(C(1:MAXvector, 1:MAXvector),1);
    % Create a zeros D matrix
    ZerosD = zeros(C_row_dimension, B_colums_dimension); % 
    Dstr = '[ ';
    for i = 1:C_row_dimension % The row dimension of C
      Dstr = strcat(Dstr , num2str(ZerosD(i, :)), ';');
    end
    
    % Remove the last ';' and then add ']' 
    Dstr = Dstr(1:end-1);
    % Add ']' at the end
    Dstr = strcat(Dstr, ']');
    
    B_colums_dimension = size(B(1:MAXvector, 1:MAXvector),2); 
    
    Hstr = '@(x,u)'; % Create the handle
    Dfun = strcat(Hstr , Dstr);
    
    % Creat the function
    D = str2func(Dfun);
    
  else
    D = varargin{4};
    r = nargin(D);
    
    % Check if D has two input vectors x and u
    if r ~= 2
      error('D need to have the function handle @(x,u)');
    end
    
    % Check if sys.C and sys.D have the same lenght of rows 
    if(size(C(1:MAXvector, 1:MAXvector),1) ~= size(D(1:MAXvector, 1:MAXvector),1))
      error('C and D have not the same row length');
    end
    % and check if sys.B and sys.D have the same lenght of columns 
    if(size(B(1:MAXvector, 1:MAXvector),2) ~= size(D(1:MAXvector, 1:MAXvector),2))
      error('D and B have not the same columns length');
    end
  end
  
  % Matrix
  sys.A = A;
  sys.B = B;
  sys.C = C;
  sys.D = D;
  
  % No delay here!
  sys.type = 'NLSS'; % Nonlinear state space
  % No sample time here!
  
end
