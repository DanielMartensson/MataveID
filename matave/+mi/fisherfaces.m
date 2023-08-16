% Fisherfaces
% This algorithm can create a model that can classify images or regular data
% This algorithm is using:
% Pooling -> Kernel Principal Component Analysis -> Linear Discriminant Analysis -> Support Vector Machine -> Logistic regression
% You will recieve a model inside fisherfaces_svm.mat file
% It contains
% - Weight matrix model_W [m*n]
% - Bias vector model_b [m]
% - Parameter vector A [m]
% - Parameter vector B [m]
% This Fisherfaces will give you the model and all you have to do is to multiply a vector image_vector [n] to get the class ID:
% x = model_w*image_vector + model_b
% p(x) = 1./(1 + exp(-(A(i)*x(i) + B(i))))
% Where p(x) is a propability vector.
% The index of the highest propability of vector p(x) is the class ID of image_vector [n]
% Author: Daniel Mårtensson, Augusti 16 2023

function fisherfaces()
  % Salut
  disp('Welcome to Fisherfaces.')
  disp('This algorithm can classify images or raw data from .pgm files in the formats P2 and P5.')
  disp('Notice that it exist an equivalent ANSI C code for this inside CControl');

  % Ask the user what it want to do
  choice = input("What do you want to do?\n1. Collect data\n2. Train projection matrix\n3. Generate PGM data from images\n4. Check pooling\n5. Train SVM model\nEnter choice number: ");

  % Switch statement for the choices
  switch(choice)
  case 1
    fisherfaces_collect_data();
  case 2
    fisherfaces_train_projection_matrix();
  case 3
    fisherfaces_generate_pgm_data();
  case 4
    fisherfaces_check_pooling();
  case 5
    fisherfaces_train_svm_model();
  otherwise
    disp('Unknown choice - Exit')
  end
end

function fisherfaces_train_svm_model()
  % Load data
  disp('Load fisherfaces_projection.mat');
  load('fisherfaces_projection.mat', 'P', 'W');
  disp('Done');

  % Load data
  disp('Loading fisherfaces_data.mat');
  load('fisherfaces_data.mat', 'images', 'class_id');
  disp('Done');

  % Ask the user about C
  C = input('What type of C value do you want for SVM: ');

  % Ask the user about lambda
  lambda = input('What type of lambda(regularization) value do you want for SVM: ');

  % Create the y vector
  classes = max(class_id);

  % Find the size of P
  [m, n] = size(P);

  % Create model
  w = [];
  model_b = [];

  % Create one SVM model per class
  for i = 1:classes
    % Create a -1 labels array
    labels = linspace(-1, -1, n);

    % Fill y with 1 for a specific class
    index = find(i == class_id);
    labels(index) = 1;

    % Do linear SVM
    [slope, b, accuracy, solution] = mi.lsvm(P', labels', C, lambda);

    % Status
    if(solution)
        fprintf('SVM OK: %s. Accuracy: %f. Class: %i\n', 'yes', accuracy, i);
    else
        fprintf('SVM OK: %s. Accuracy: %f. Class: %i\n', 'no', accuracy, i);
    end

    % Save model
    w = [w; slope];
    model_b = [model_b; b];
  end

  disp('Done with SVM')
  disp('Multiply model_w = w * W')
	disp('x = model_w*image_vector + model_b is our model')
  disp('p(x) = 1./(1 + exp(-(A(i)*x(i) + B(i))))');
  disp('The image_vector must be in row-major, not column-major');
  disp('e.g the image/data you want to classify is going to be in row-wise, not column-wise.')
	disp('The model will give us a vector x that contains scores.')
	disp('The scores x are feed into a sigmoid function that computes the propability vector p(x)')
	disp('The index of the highest propability in vector p(x) is the class ID')

  % Compute model
  model_w = w*W;

  % Compute the scores and labels
  X = model_w*images + model_b;
  Y = sign(X);

  % Create matrix for 2 values, A and B
  AB = zeros(classes, 2);

  % Use Platt's method as logistic regression
  x0 = [0; 0];
  for i = 1:classes
    % Extract one row of the labels
    y = Y(i, :);
    x = X(i, :);

    % Create the sigmoid with -1 to 1
    sigmoid = @(parameters) 1./(1 + exp(-parameters(1).*x - parameters(2)));

    % Create Platt's loss
    platt_loss = @(parameters) 1/n*sum((sigmoid(parameters) - (y == 1)).^2);

    % Optimize and find the parameters A and B
    parameters = mc.fminsearch(platt_loss, x0);
    A(i) = parameters(1);
    B(i) = parameters(2);
  end

  % Now we have our model. Compute the ID
  disp('Saving model_w, model_b and parameters A and B inside fisherfaces_svm.mat');
  save('fisherfaces_svm.mat', 'model_w', 'model_b', 'A', 'B');
  disp('Done');
end

function fisherfaces_train_projection_matrix()
  % Load data
  disp('Loading fisherfaces_data.mat');
  load('fisherfaces_data.mat', 'images', 'class_id');
  disp('Done');

  % Ask the user what type of kernel type should be used
  kenel_type_id = input("What kernel type do you want to use?\n1. Linear\n2. Polynomial\n3. Gaussian\n4. Exponential\n5. Sigmoid\n6. RBF\nEnter choice number: ");
  switch(kenel_type_id)
  case 1
    kernel_type = 'linear';
    kernel_parameters = '';
  case 2
    kernel_type = 'polynomial';
    kernel_parameters = input("Enter degree value: ");
  case 3
    kernel_type = 'gaussian';
    kernel_parameters = input("Enter sigma value: ");
  case 4
    kernel_type = 'exponential';
     kernel_parameters = input("Enter sigma value: ");
  case 5
    kernel_type = 'sigmoid';
    kernel_parameters(1) = input("Enter alpha value: ");
    kernel_parameters(2) = input("Enter beta value: ");
  case 6
    kernel_type = 'rbf';
    kernel_parameters = input("Enter gamma value: ");
  otherwise
    error('Unknown kernel type');
  end

  % Get size of images
  [m, n] = size(images);

  % Get the amount of classes
  classes = max(class_id);

  % Reduce dimmension of images
  cpca = input('How many dimensions for KPCA algorithm: ');

  % Do KPCA
  [Ppca, Wpca] = mi.kpca(images, cpca, kernel_type, kernel_parameters);

  % Reduce dim(Ppca) to the amount of classes - 1
  clda = classes - 1;

  % Do LDA
  [Plda, Wlda] = mi.lda(Ppca, class_id, clda);

  % Get the projection matrix
  W = Wlda'*Wpca';
  P = W*images;

  % Save the projection matrix
  disp('Saving fisherfaces_projection.mat');
  save('fisherfaces_projection.mat', 'W', 'P');
  disp('Done');
end

function fisherfaces_check_pooling()
  % Ask the user of a file path to an image
  file_path = input("Enter the file path to an image: ", 's');

  % Load imwrite (if using Octave)
  if ~isempty(ver('Octave'))
   pkg load image
  end

  % Read the image
  image = imread(file_path);

  % Turn the image to gray scale if needed
  [~, ~, l] = size(image);
  if(l > 1)
    image = rgb2gray(image);
  end

  % Show the original image
  imshow(image);
  title(sprintf('Original image with size %ix%i', size(image)))

  % Ask the user about pooling
  happy = 0;
  fig = 0;
  while(happy == 0)
    pooling_method = input("What pooling method do you want to use?\n1. Max pooling\n2. Average pooling\n3. Shape pooling\nEnter choice number: ");
    p = input("What pooling size do you want to use? ");

    % Generate pooling
    P = pooling(double(image), pooling_method, p);

    % Show the image
    if(fig > 0)
      figure(fig);
      imshow(uint8(P));
    else
      fig = figure;
      imshow(uint8(P));
    end
    title(sprintf('Pooled image with size %ix%i', size(P)))

    % Ask the user if it's done
    happy = input("Are you happy with the result? 1 = Yes, 0 = No: ");
  end

  % Salut
  disp('Done...');
end

function fisherfaces_generate_pgm_data()
  % Ask the user where the images are
  sub_folder_path = input("Enter the folder path of the sub folders: ", 's');

  % Load imwrite (if using Octave)
  if ~isempty(ver('Octave'))
   pkg load image
  end

  % Scan the folder names
  sub_folder_names = dir(sub_folder_path);

  % Loop
  for i = 1:length(sub_folder_names)
    % Check if it's a directory
    if(sub_folder_names(i).isdir)
      % Check if the folder name is . or ..
      sub_folder_name = sub_folder_names(i).name;

      if(and(~strcmp(sub_folder_name, '.'), ~strcmp(sub_folder_name, '..')))
        % Combine sub_folder_name with sub_folder_path
        sub_file_folder_path = strcat(sub_folder_path, '\', sub_folder_name);

        % Scan the files
        file_names = dir(sub_file_folder_path);

        % Loop
        for j = 1:length(file_names)
          % Check if it's a file
          if(~file_names(j).isdir)
           % Ge the file name
            file_name = file_names(j).name;

            % Cannot be a .pgm file
            if(endsWith(file_name, '.pgm'))
              continue;
            end

            % Create the total file path
            total_file_path = strcat(sub_file_folder_path, '\', file_name);

            % Read the image
            image = imread(total_file_path);

            % Turn the image to gray scale if needed
            [~, ~, l] = size(image);
            if(l > 1)
              image = rgb2gray(image);
            end

            % Save the image as .pgm
            [folder, fileName, fileExt] = fileparts(total_file_path);
            total_file_path = strcat(folder, '\', fileName, '.pgm');
            fprintf('Creating image: %s\n', total_file_path);
            imwrite(image, total_file_path);

          end
        end
      end
    end
  end
  disp('Done');
end

function fisherfaces_collect_data()
  % Ask the user where the images are
  sub_folder_path = input("Enter the folder path of the sub folders: ", 's');

  % Ask the user if the user want pooling
  use_pooling = input("Do you want to use pooling? 1 = Yes, 0 = No: ");

  % If pooling is used
  if(use_pooling == 1)
    % Ask the user what pooling method sould be used
    pooling_method = input("What pooling method do you want to use?\n1. Max pooling\n2. Average pooling\n3. Shape pooling\nEnter choice number: ");
    p = input("What pooling size do you want to use? ");
  end

  % Scan the folder names
  sub_folder_names = dir(sub_folder_path);

  % Create the images holder
  images = [];
  class_id = [];
  counted_class_id = 0;

  % Loop
  for i = 1:length(sub_folder_names)
    % Check if it's a directory
    if(sub_folder_names(i).isdir)
      % Check if the folder name is . or ..
      sub_folder_name = sub_folder_names(i).name;

      if(and(~strcmp(sub_folder_name, '.'), ~strcmp(sub_folder_name, '..')))
        % Combine sub_folder_name with sub_folder_path
        sub_file_folder_path = strcat(sub_folder_path, '\', sub_folder_name);

        % Scan the files
        file_names = dir(sub_file_folder_path);

        % Count class id
        counted_class_id = counted_class_id + 1;

        % Loop
        for j = 1:length(file_names)
          % Check if it's a file
          if(~file_names(j).isdir)
           % Ge the file name
            file_name = file_names(j).name;

            % Must be a .pgm file
            if(~endsWith(file_name, '.pgm'))
              continue;
            end

            % Create the total file path
            total_file_path = strcat(sub_file_folder_path, '\', file_name);
            fprintf('Reading: %s\n', total_file_path);

            % Read the image
            image = imread(total_file_path);

            % Turn the image to gray scale if needed
            [~, ~, l] = size(image);
            if(l > 1)
              image = rgb2gray(image);
            end

            % Create image to double data type
            image = double(image);

            % Use pooling
            if(use_pooling == 1)
              image = pooling(image, pooling_method, p);
            end

            % Read the images in row major
            image_vector = [];
            m = size(image, 1);
            for k = 1:m
              image_vector = [image_vector image(k, :)];
            end

            % Add the image vector transpose to images
            images = [images image_vector'];
            class_id = [class_id counted_class_id];
          end
        end
      end
    end
  end

  % Save the images and class_id
  disp('Saving fisherfaces_data.mat');
  save('fisherfaces_data.mat', 'images', 'class_id');
  disp('Done');

end

function P = pooling(image, pooling_method, p)
  % Size of A
	[m, n] = size(image);

	% P size
	h = floor(m / p);
	w = floor(n / p);
	P = zeros(h, w);

	% Minimal case
	a = mean(image(:));
	b = max(image(:));

	% Process
	for i = 1:h
		for j = 1:w
			% Cut
			start_row = (i - 1) * p + 1;
			stop_row = i * p;
			start_column = (j - 1) * p + 1;
			stop_column = j * p;
			B = image(start_row:stop_row, start_column:stop_column);

			% Do pooling
      switch(pooling_method)
      case 1
        P(i, j) = max(B(:)); % Max pooling
      case 2
        P(i, j) = mean(B(:)); % Average pooling
      case 3
        P(i, j) = mean(B(:))/a*b; % Shape pooling
      otherwise
        error('Unknown pooling method');
      end
		end
	end
end
