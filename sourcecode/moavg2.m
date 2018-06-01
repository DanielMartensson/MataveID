% Use moving moavg2 average to filter the noise
% Returns the filtered curve
% Example [x_filter, y_filter] = moavg2(x, y, factor);
% Author: Daniel Mårtensson, April 2018

function [B1_s_filter, B1_f_filter] = moavg2 (varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
  end
  
  % Get the x
  if(length(varargin) >= 1)
    x = varargin{1};
  else
    error('Missing x')
  end
  
  % Get the y
  if(length(varargin) >= 2)
    y = varargin{2};
  else
    error('Missing y');
  end
  
  % Get the filtering factor
  if(length(varargin) >= 3)
    punkt = varargin{3};
  else
    error('Missing filtering factor');
  end
  
  % Plot x and y
  plot(x, y);
  
  titel = strcat('Raw data curve');
  title(titel, 'FontSize', 15)
  xlabel('x', 'FontSize', 15)
  ylabel('y', 'FontSize', 15)
  set(gca, 'FontSize', 15)
  grid on
  
  % Do filtering
  B1_f = y;
  B1_s = x;
  
  % Arrays and temporary holders
  B1_f_filter = [];
  B1_s_filter = [];
  B1_f_temp = 0;
  B1_s_temp = 0;

  % this filtering works as it sums X values before + a value + X values after, then divide it into the amount of values.
  % For punkt = 2, it will be: X(-2)X(-1) + X(1) + X(2)X(3), then devide them into 5. 
  % For punkt = 4, it will be: X(-4)X(-3)X(-2)X(-1) + X(1) + X(2)X(3)X(3)X(4), then devide them into 9. 
  % Notice that X(-negative) vill be X(1) and X(+limit) will be X(end)
  for i = 1:length(B1_f)
     if i <= punkt
       % Radera
       B1_f_temp = 0;
       B1_s_temp = 0;
       
       for j = 1:punkt
         B1_f_temp = B1_f_temp + B1_f(1) + B1_f(j+1);
         B1_s_temp = B1_s_temp + B1_s(1) + B1_s(j+1);
       end
       B1_f_filter(i) = (B1_f_temp + B1_f(j))/(punkt*2 + 1);
       B1_s_filter(i) = (B1_s_temp + B1_s(j))/(punkt*2 + 1);
       
     elseif i >= (length(B1_f) - punkt)
       % Radera
       B1_f_temp = 0;
       B1_s_temp = 0;
       
       for j = 1:punkt
         B1_f_temp = B1_f_temp + B1_f(i-j) + B1_f(end);
         B1_s_temp = B1_s_temp + B1_s(i-j) + B1_s(end);
       end
       B1_f_filter(i) = (B1_f_temp + B1_f(i))/(punkt*2 + 1);
       B1_s_filter(i) = (B1_s_temp + B1_s(i))/(punkt*2 + 1);
       
     else
       % Radera
       B1_f_temp = 0;
       B1_s_temp = 0;
       
       for j = 1:punkt
         B1_f_temp = B1_f_temp + B1_f(i-j) + B1_f(i+j);
         B1_s_temp = B1_s_temp + B1_s(i-j) + B1_s(i+j);
       end
       B1_f_filter(i) = (B1_f_temp + B1_f(i))/(punkt*2 + 1);
       B1_s_filter(i) = (B1_s_temp + B1_s(i))/(punkt*2 + 1);
     end
     
  end

  % Plot the new filtered curve with moving median average
  figure
  plot(B1_s_filter, B1_f_filter);

  titel = strcat('Filtered curve');
  title(titel, 'FontSize', 15)
  xlabel('x', 'FontSize', 15)
  ylabel('y', 'FontSize', 15)
  set(gca, 'FontSize', 15)
  grid on
end
