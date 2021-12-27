% Support Vector Machine with C code generation
% Input: X(data in x-axis), Y(data in y-axis)
% Example 1: svm(X, Y);
% Author: Daniel Mårtensson, December 2021

function svm(X, Y)
  % First print our data 
  [legend_labels] = print_data(X, Y);
  
  % Then place out our support points 
  [X_point, Y_point, amount_of_supports_for_class] = place_out_supports_points(X, Y, legend_labels);
  
  % Check if our support points works
  check_points_support(X, Y, X_point, Y_point);
  
  % Ask the user what the file name should have 
  [file_name] = ask_user_about_file_name();
  
  % Generate C code
  [c_source, c_header] = generate_c_code(X_point, Y_point, amount_of_supports_for_class, file_name);
  
  % Save the C code into a file 
  save_c_code_into_a_file(c_source, c_header, file_name);
end

function [legend_labels] = print_data(X, Y)
  % Get the amount of classes 
  c = size(X, 1);
    
  % Plot the data classes 
  legend_labels = {};
  for i = 1:c
    scatter(X(i, :), Y(i, :));
    hold on
    legend_labels{i} = sprintf('Data %i', i);
  end
  legend(legend_labels);
  grid on
end

function [X_point, Y_point, amount_of_supports_for_class] = place_out_supports_points(X, Y, legend_labels)
  % Get the amount of classes 
  c = size(X, 1);

  % Start set out the supports points
  X_point = zeros(c, 256);
  Y_point = zeros(c, 256);
  amount_of_supports_for_class = zeros(1, c);
  for i = 1:c
    % buttonnumber == 1 indicates left click
    % buttonnumber == 3 indicates right click
    buttonnumber = 1;
    j = 1;
    title(sprintf('Set out SVM points for Data %i', i), 'FontSize', 30);
    while buttonnumber == 1
      % Left-click on the scatter plot
      [x, y, buttonnumber] = ginput(1); 
      
      % Abort to next data set
      if(buttonnumber == 3)
        break;
      end
      
      % Place the x and y - 
      X_point(i, j) = x;
      Y_point(i, j) = y;
      
      % Remember how many points we have set ut for each data class
      amount_of_supports_for_class(i) = amount_of_supports_for_class(i) + 1;
      
      % Plot the dots as a line 
      X_line = X_point(i, 1:j);
      Y_line = Y_point(i, 1:j);
      if(length(X_line) == 1)
        scatter(X_line, Y_line, '.')  
      else
        plot(X_line, Y_line, '-k')  
      end
      
      % Place out the legends so we don't get new legends
      legend(legend_labels)
      
      % Increment 
      j = j + 1;
    end
    
    % The last line will close the gap between the end and the beginning
    X_point(i, j) = X_point(i, 1);
    Y_point(i, j) = Y_point(i, 1);
      
    % Remember how many points we have set ut for each data class
    amount_of_supports_for_class(i) = amount_of_supports_for_class(i) + 1;
      
    % Plot the points as a line 
    X_line = X_point(i, 1:j);
    Y_line = Y_point(i, 1:j);
    plot(X_line, Y_line, '-k')  

    % Place out the legends so we don't get new legends
    legend(legend_labels)
  end
end

function check_points_support(X, Y, X_point, Y_point)
  % Get the amount of classes 
  c = size(X_point, 1);

  % Do a quick check if the SVM points are correctly placed
  for i = 1:c
    % Get the points 
    all_X_points = X_point(i, :);
    all_Y_points = Y_point(i, :);
    
    % Begin to count 
    counted_points = sum(inpolygon(X(i,:) , Y(i, :), all_X_points, all_Y_points));
    if(counted_points == length(X(i, :)))
      disp(sprintf('Checking for class %i is OK - Good generated SVM supports', i));
    else
      error(sprintf('Checking for class %i failed beacause the generated SVM points excluding data', i));
    end
  end
end

function [file_name] = ask_user_about_file_name()
  file_name = cell2mat(inputdlg('Enter a file name without file extension', 'Support Vector Machine C code generation'));
  if(length(file_name) == 0)
    error('You need to enter a file name!');
  end
end

function [c_source, c_header] = generate_c_code(X_point, Y_point, amount_of_supports_for_class, file_name)
  % We round down to 3 decimals 
  X_point = round(X_point*1000)/1000;
  Y_point = round(Y_point*1000)/1000;
  
  % Find maximum column for X_point_str and Y_point_str 
  len_px_py = max(amount_of_supports_for_class);
  
  % Create svm_classes
  svm_classes = size(X_point, 1);
  
  % This is only for the C code. In C, we want to place .f after every float value beacause setting 0f will give an error in C
  for i = 1:svm_classes
    X_point(i, 1 + amount_of_supports_for_class(i):len_px_py) = 0.1; % Any float number will be OK. The C code will not read it anyway
    Y_point(i, 1 + amount_of_supports_for_class(i):len_px_py) = 0.1;
  end
  
  % Create px matrix 
  px = regexprep(mat2str(X_point(:, 1:len_px_py)), {']', '\[', ';', ' '}, {'', '', 'f,', 'f,'});

  % Create py matrix
  py = regexprep(mat2str(Y_point(:, 1:len_px_py)), {']', '\[', ';', ' '}, {'', '', 'f,', 'f,'});
  
  % Create p array
  p = regexprep(mat2str(amount_of_supports_for_class), {']', '\[', ' '}, {'', '', ','});
  
  % Write this c source into a file
  c_source = {sprintf('#include "%s.h"', file_name);
  '/*'
  ' * Support vector machine for classification using CControl library'
  ' * x[m] = Data in x-axis'
  ' * y[m] = Data in y-axis'
  ' * threshold = A positive number for determine how much we should trust the selected class'
  ' *'
  ' * This function can handle 255 classes. It will return a number the class number beginning from 1 to 255'
  ' * If the function returns 0, then it means no class has been found. Try to use another lower threshold value then'
  ' */'
  sprintf('#define svm_classes %i        /* How many classes this this SVM function handle */', svm_classes);
  sprintf('#define len_px_py %i          /* Length of the px and py matrix */', len_px_py);
  ''
  sprintf('uint8_t %s(float x[], float y[], uint16_t m, uint16_t threshold){', file_name);
  ''
  '  /* Create the polygon coordinates */'
  sprintf('  float px[svm_classes*len_px_py] = {%s};', px);
  sprintf('  float py[svm_classes*len_px_py] = {%s};', py);
  ''
  '  /* How much data in each line of the polygon coordinates */'
  sprintf('  uint8_t p[svm_classes] = {%s};', p);
  ''
  '  /* Perform SVM to find the class index */'
  '  uint16_t point_counter;'
  '  uint16_t max_points = 0;'
  '  uint8_t class_index = 0;'
  '  for(uint8_t i = 0; i < svm_classes; i++){'
  '    /* Reset point counter */'
  '    point_counter = 0;'
  ''
  '    /* Count how many points the data gives for each class */'
  '    for(uint16_t j = 0; j < m; j++)'
  '      point_counter += (uint8_t) point_in_polygon(x[j], y[j], &px[i*len_px_py], &py[i*len_px_py], p[i]);'
  ''
  '    /* Remember the max points */'
  '    if(point_counter > max_points){'
  '      max_points = point_counter;'
  '      class_index = i+1;'
  '    }'
  '  }'
  ''
  '  /* Use the threshold for determine if the max_points should be trusted */'
  '  if(max_points >= threshold)'
  '    return class_index;'
  '  else'
  '    return 0; /* No class was found */'
  '}'};
  
  % Create the header file
  c_header = {sprintf('#ifndef %s', strcat(upper(file_name), '_H_'));
  sprintf('#define %s', strcat(upper(file_name), '_H_'))
  ''
  '#include "CControl/Headers/Functions.h" /* You need to point this location to the CControl header file */'
  ''
  '#ifdef __cplusplus'
  'extern "C" {'
  '#endif'
  ''
  sprintf('uint8_t %s(float x[], float y[], uint16_t m, uint16_t threshold);', file_name);
  ''
  '#ifdef __cplusplus'
  '}'
  '#endif'
  ''
  '#endif'};
  
end

function save_c_code_into_a_file(c_source, c_header, file_name)
  % Create the source file 
  fid = fopen(strcat(file_name, '.c'), 'wt');
  for i = 1:size(c_source, 1)
    fprintf(fid, "%s\n", cell2mat(c_source(i)));
  end
  fclose(fid);
  
  % Create the header file 
  fid = fopen(strcat(file_name, '.h'), 'wt');
  for i = 1:size(c_header, 1)
    fprintf(fid, "%s\n", cell2mat(c_header(i)));
  end
  fclose(fid);
end
