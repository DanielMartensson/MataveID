% This is an example for more than 3 columns of X.
% Here we cannot plot this 9D table because nobody knows how to plot 9D plots.

% Data - Each column inside the table is a sensor
X = [% Class B table
     5 3 2 2 4 5 6 7 3;
     2 1 3 3 3 4 3 2 5;
     7 2 4 3 1 9 4 2 4;
     8 3 1 1 5 7 8 2 9;
     9 1 2 2 3 1 5 3 2;

     % Class A table
     15 23 23 32 43 52 13 64 34;
     17 18 13 34 54 10 45 99 77;
     18 13 63 56 33 95 35 65 55;
     16 20 24 93 94 23 56 87 77;
     19 15 52 36 20 45 44 22 32];

% Labels of the data for each class
y = [1; % Class B
     1;
     1;
     1;
     1;
     -1; % Class A
     -1;
     -1;
     -1;
     -1];

% Tuning parameters
C = 1;              % For upper boundary limit
lambda = 1;         % Regularization (Makes it faster to solve the quadratic programming)

% Compute weigths, bias and find accuracy
[w, b, accuracy, solution] = mi.lsvm(X, y, C, lambda);

% Classify
x_unknown = [15; 5; 7; 2; 4; 6; 3; 5; 2];
class_ID = sign(w*x_unknown + b)
if(class_ID > 0)
  disp('x_unknown class B')
else
  disp('x_unknown is class A')
end
