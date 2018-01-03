% Use the mouse cursor to do a hand-made-curve fitting
% Returns noise free y and the noise e
% Example [t, y, e] = smoothing(t, y);
% Author: Daniel Mårtensson, November 2017

function [t, y, e] = smoothing(varargin)
  % Check if there is any input
  if(isempty(varargin))
    error('Missing imputs')
  end
  
  % Get the time
  if(length(varargin) >= 1)
    t = varargin{1};
  else
    error('Missing time')
  end
  
  % Get the signal
  if(length(varargin) >= 2)
    y = varargin{2};
  else
    error('Missing signal');
  end
  
  chooise = 'No'; % Initial choise
  
  % While our choise is 'No', the continue to extract data
  while strcmp(chooise, 'No')
    % Plot the signal
    plot(t, y, 'b'); 
    fig = gcf; % Get current figure handle
    % Zoom
    title('Use the mouse cursor and press dots on the signal. Press right button to finish')
    ylim([min(y) max(y)]); 
    xlim([min(t) max(t)]);
    legend('Measured')
    
    % Start place dots over the signal
    buttonnumber = 1; % Initial choise
    dt = [];
    dy = [];
    while buttonnumber == 1
      [dttemp, dytemp, buttonnumber] = ginput(1); 
      
      % This makes sure that if you want to finish and the have placed the cursor 
      % at wrong place, you don't want to have this here. buttonnumber == 3 indicates right click. 
      % buttonnumber == 1 indicates left click
      if(buttonnumber == 1)
        dt = [dt dttemp];
        dy = [dy dytemp];
      end
      
      % Plot
      clf(fig)
      plot(t, y, 'b', dt, dy, 'r'); 
      title('Use the mouse cursor and press dots on the signal. Press right button to finish')
      ylim([min(y) max(y)]); 
      xlim([min(t) max(t)]);
      legend('Measured', 'Extracted')
      
      % Get length of dy 
      n = length(dy);
      legend('Measured', strcat('Extracted:', num2str(n)))
    end
    
    % Ask the user if the user is happy with the result
    questiontxt = sprintf('Is the result OK?\nPress No if you want to repeat.\nPress Yes if you accept the result.');
    chooise = questdlg (questiontxt, 'Question', 'Yes', 'No', 'No');
    
    % Check the user choise
    if strcmp(chooise, 'Yes')
      % Last thing to do is the estimate the scalar of the noise
      
      chooise = 'No'; % Initial choise
      while strcmp(chooise, 'No')
         scalar = inputdlg('Give a scalar of noise', 'Scalar');
         scalar = str2num(cell2mat(scalar));
         de = scalar*randn(1, length(dy)); 
         
         % clear the figure
         clf(fig)
         % Plot
         plot(t, y, 'b', dt, dy, 'r', dt, dy + de , 'g'); 
         legend('Measured', 'Extracted', 'Generated')
         ylim([min(y) max(y)]); 
         xlim([min(t) max(t)]);
         title('Compare the noise')
         
         % Ask the user if the user is happy with the result
         questiontxt = sprintf('Is the result OK?\nPress No if you want to repeat.\nPress Yes if you accept the result.');
         chooise = questdlg(questiontxt, 'Question', 'Yes', 'No', 'No');
        
        if strcmp(chooise, 'Yes')
          % Break and send back!
          e = de;
          y = dy;
          t = dt;
          break; 
        elseif strcmp(chooise, 'No')
          % clear the figure
          clf(fig)
        end
      end
    elseif strcmp(chooise, 'No')
      % clear the figure
      clf(fig)
    end
  end
  
end
