

function generalizedhough()
  % Salut
  disp('Welcome to Generalized Hough Transform.')
  disp('This algorithm can classify images or raw data from .pgm files in the formats P2 and P5.')
  disp('Notice that it exist an equivalent ANSI C code for this inside CControl');

  % Ask the user what it want to do
  choice = input("What do you want to do?\n1. Create data\n2. Create Hough model\n3. Evaluate votes\nEnter choice number: ");

  % Switch statement for the choices
  switch(choice)
  case 1
    generalizedhough_create_data();
  case 2
    generalizedhough_create_model();
  case 3
    generalizedhough_eval_votes();
  otherwise
    disp('Unknown choice - Exit')
  end
end

function generalizedhough_create_data()
  % Load image
  X = load_image();

  % Tune in the best settings
  happy = 0;
  fig = 0;
  while(happy == 0)
    if(fig > 0)
      close(fig);
    end
    fig = imshow(X);
    hold on

    % Ask the user about parameters
    sigma = input("Enter sigma for harris score(0.01 to 20): ");
    threshold = input("Enter threshold for FAST(1 to 255): ");
    fast_method = input("Enter FAST method(9, 10, 11, 12): ");
    num_features = input("Enter how many FAST features: ");
    epsilon = input("Enter epsilon for DBSCAN: ");
    min_pts = input("Enter minimum points for DBSCAN: ");

    % Sobel
    X = mi.sobel(X);
    X(X < 255) = 0;

    % Compute harris score
    H = harris(X, sigma);

    % Compute fast
    corners = mi.fast(X, threshold, fast_method);

    % Get corners
    N = size(corners, 1);
    M = zeros(N, 1);
    M = H(sub2ind(size(H), corners(:, 2), corners(:, 1)));

    % Sort
    [~, index] = sort(M, 'descend');

    % Trim
    if(N < num_features)
      num_features = N;
    end

    % Replace the image with feature points
    P = corners(index, :);
    P = P(1:num_features, :);

    % Do DBSCAN
    idx = mi.dbscan(P, epsilon, min_pts);

    % Find centroid of each cluster
    total_clusters = max(idx);
    C = zeros(total_clusters, 2);
    for i = 1:total_clusters
      C(i, :) = mean(P(idx == i, :));
    end

    % Show scatter of centroids
    scatter(C(:, 1), C(:, 2), 'r', 'filled');
    title(sprintf('Harris sigma = %i, FAST threshold = %i, FAST method = %i, number of features = %i, epsilon = %i, minimum points = %i', sigma, threshold, fast_method, num_features, epsilon, min_pts));

    % Ask the user if it's done
    happy = input("Are you happy with the result? 1 = Yes, 0 = No: ");
    if(happy == 0)
      title('');
    end
  end

  % Rename C to X
  X = C;

  % Save
  disp('Savning data');
  save('generalized_hough_data.mat', 'X');
end

function generalizedhough_create_model()
  % Load generalized hough data
  load('generalized_hough_data.mat');

  % Constants and variables
  [m, n] = size(X);

  % Find centroid
  C = mean(X);

  % Find the distances
  D = sqrt(distEucSq(X, X));

  % Sort distances and also the index
  [S, index] = sort(D, 2, 'ascend');

  % Create generalized hough model
  model = repmat(struct('votes_active', 0, 'vote', []), 1, 181);

  % Create rod2d
  rot2d = @(x, theta) ([cos(theta) -sin(theta); sin(theta) cos(theta)]*x);

  % Create the accumulator array
  P = ceil(max(X));
  pm = P(1);
  pn = P(2);
  accumulator = zeros(pm, pn);

  % Find the angles between vectors from each cluster point
  for i = 1:m
    % Status
    fprintf("Training: %i of %i points left\n", i, m);

    % Get the first point
    target = X(index(i, 1), :);

    % Get the closest point
    vector_A = X(index(i, 2), :);

    % Get the second closest point
    vector_B = X(index(i, 3), :);

    % Debug
    debug = false;
    if(debug)
      hold on
      plot([target(1), C(1)], [target(2), C(2)]);
      plot([target(1), vector_A(1)], [target(2), vector_A(2)]);
      plot([target(1), vector_B(1)], [target(2), vector_B(2)]);
      hold off
    end

    % Center
    vector_A = vector_A - target;
    vector_B = vector_B - target;
    vector_C = C - target;

    % Compute the angle between vectors
    theta = floor(anglevector(vector_A, vector_B)) + 1;
    alpha1 = anglevector(vector_A, vector_C);
    alpha2 = anglevector(vector_B, vector_C);

    % Compute the euclidean distance
    RA = norm(vector_A, 2);
    RB = norm(vector_B, 2);
    RC = norm(vector_C, 2);

    % Allocate new vote
    votes_active = model(theta).votes_active + 1;
    model(theta).vote = [model(theta).vote struct('alpha', 0, 'R', 0, 'shortest', 0)];

    % Save shortest of RA and RB - This is used for scaling
    if(RA < RB)
      model(theta).vote(votes_active).shortest = RA;
      model(theta).vote(votes_active).alpha = alpha1;
    else
      model(theta).vote(votes_active).shortest = RB;
      model(theta).vote(votes_active).alpha = alpha2;
    end

    % Compute the euclidean distance between centroid and target
    model(theta).vote(votes_active).R = RC;

    % Count
    model(theta).votes_active = votes_active;

    % Estimate the centroid
    for j = 1:2
      % Once again, select the unit vector because in the estimation, the vector_C is unknown
      if(RA < RB)
        unit_vector = vector_A;
      else
        unit_vector = vector_B;
      end

      % Check direction
      if(j == 1)
        alpha = 360 - model(theta).vote(votes_active).alpha;
      else
        alpha = model(theta).vote(votes_active).alpha;
      end

      % Create the unit vector by using L2-norm
      unit_vector = unit_vector ./ norm(unit_vector, 2);

      % Rotate the unit vector
      unit_vector = rot2d(unit_vector', deg2rad(alpha));
      unit_vector = model(theta).vote(votes_active).R.*unit_vector';

      % Compute the xc and xy
      xc_yc = unit_vector + target;
      xc = ceil(xc_yc(1));
      yc = ceil(xc_yc(2));

      % Save in the accumulator array
      if(and(xc > 1, yc > 1, xc <= pm, yc <= pn))
        accumulator(xc, yc) = accumulator(xc, yc) + 1;
      end
    end
  end

  % Find the largest value inside the accumulator array
  [~, index] = max(accumulator(:));
  [xc, yc] = ind2sub(size(accumulator), index);

  % Display
  fprintf('The centroid was [%i, %i].\nThe estimated centroid was [%i, %i]\n', C(1), C(2), xc, yc);

  % Save
  disp('Saving model');
  save('generalized_hough_model.mat', 'model');
end

function generalizedhough_eval_votes()
  % Load generalized hough model and data
  load('generalized_hough_model.mat');
  load('generalized_hough_data.mat');

  % Get size of X
  [m, n] = size(X);

  % Create the accumulator array
  P = ceil(max(X));
  pm = P(1);
  pn = P(2);
  accumulator = zeros(pm, pn);

  % Create rod2d
  rot2d = @(x, theta) ([cos(theta) -sin(theta); sin(theta) cos(theta)]*x);

  % Find the distances
  D = sqrt(distEucSq(X, X));

  % Sort distances and also the index
  [S, index] = sort(D, 2, 'ascend');

  % Find the angles between vectors from each cluster point
  for i = 1:m
    % Status
    fprintf("Evaluate: %i of %i points left\n", i, m);

    % Get the first point
    target = X(i, :);

    % Get the closest_point
    vector_A = X(index(i, 2), :);

    % Get the second closest point
    vector_B = X(index(i, 3), :);

    % Debug
    debug = false;
    if(debug)
      hold on
      plot([target(1), vector_A(1)], [target(2), vector_A(2)]);
      plot([target(1), vector_B(1)], [target(2), vector_B(2)]);
    end

    % Center
    vector_A = vector_A - target;
    vector_B = vector_B - target;

    % Compute the angle between vectors
    theta = floor(anglevector(vector_A, vector_B)) + 1;

    % Compute the euclidean distance
    RA = norm(vector_A, 2);
    RB = norm(vector_B, 2);

    % Get the shortest distance
    if(RA < RB)
      shortest = RA;
    else
      shortest = RB;
    end

    % Compare votes
    for j = 1:model(theta).votes_active
      % Display
      fprintf("Evaluate: %i of %i votes left at theta %i\n", j, model(theta).votes_active, theta);

      % Compute the ratio for scaling
      ratio = shortest / model(theta).vote(j).shortest;

      % Compute the R distance
      R = ratio * model(theta).vote(j).R;

      % Estimate the centroid
      for k = 1:2
        % Once again, select the unit vector because in the estimation, the vector_C is unknown
        if(RA < RB)
          unit_vector = vector_A;
        else
          unit_vector = vector_B;
        end

        % Check direction
        if(k == 1)
          alpha = 360 - model(theta).vote(j).alpha;
        else
          alpha = model(theta).vote(j).alpha;
        end

        % Create the unit vector by using L2-norm
        unit_vector = unit_vector ./ norm(unit_vector, 2);

        % Rotate the unit vector
        unit_vector = rot2d(unit_vector', deg2rad(alpha));
        unit_vector = R.*unit_vector';

        % Compute the xc and xy
        xc_yc = unit_vector + target;
        xc = ceil(xc_yc(1));
        yc = ceil(xc_yc(2));

        % Save in the accumulator array
        if(and(xc > 1, yc > 1, xc <= pm, yc <= pn))
          accumulator(xc, yc) = accumulator(xc, yc) + 1;
        end
      end
    end
  end

  % Do gaussian smoothing on the peaks
  accumulator = mi.imgaussfilt(accumulator, 5);
  debug = false;
  if(debug)
    surf(accumulator)
  end

  % Find the largest value inside the accumulator array
  [max_value, index] = max(accumulator(:));
  [xc, yc] = ind2sub(size(accumulator), index);

  % Display
  hold on
  fprintf('The estimated centroid was [%i, %i] and the max value was %i\n', xc, yc, max_value);
  scatter(xc, yc, 'x', 'linewidth', 10);
end

function angleDegrees = anglevector(a, b)
  % Calculate the dot product
  dotProduct = dot(a, b);

  % Calculate the lengths of the vectors
  lengthA = norm(a, 2);
  lengthB = norm(b, 2);

  % Calculate the cosine of the angle
  cosineAngle = dotProduct / (lengthA * lengthB);

  % Ensure that cosineAngle is within the range[-1, 1]
  cosineAngle = min(max(cosineAngle, -1), 1);

  % Use atan2 to get the angle in radians
  angleRadians = atan2(sqrt(1 - cosineAngle * cosineAngle), cosineAngle);

  % Convert the angle from radians to degrees
  angleDegrees = rad2deg(angleRadians);
end

function H = harris(I, sigma)
  % Gray scale
  if(size(I, 3) > 1)
	  I = rgb2gray(I);
  end
    I = double(I);

  % No edge
  r = 0;

  % Sobel
  dx = [-1 0 1; -2 0 2; -1 0 1];
  dy = [-1 -2 -1; 0 0 0; 1 2 1];
  Ix = conv2(I, dx, 'same');
  Iy = conv2(I, dy, 'same');

  % Create mesh grid
  kernel_size = round(6 * sigma);
  [x, y] = meshgrid(-kernel_size:kernel_size, -kernel_size:kernel_size);

  % Create gaussian 2D kernel
  g = 1/(2*pi*sigma^2)*exp(-(x.^2 + y.^2)/(2*sigma^2));

  Ix2 = mc.conv2fft(Ix.^2, g);
  Iy2 = mc.conv2fft(Iy.^2, g);
  Ixy = mc.conv2fft(Ix.*Iy, g);

  k = 0.04;
  Hp = (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2;

  % Normalize
  H = (10000/max(abs(Hp(:))))*Hp;

  % set edges zeros
  H(1:r,:) = 0;
  H(:,1:r) = 0;
  H(end-r+1:end,:) = 0;
  H(:,end-r+1:end) = 0;
end

function D = distEucSq(X, Y)
  Yt = Y';
  XX = sum(X.*X, 2);
  YY = sum(Yt.*Yt, 1);
  D = abs(bsxfun(@plus, XX, YY) - 2*X*Yt);
end

function X = load_image()
  % Ask the user of a file path to an image
  file_path = input("Enter the file path to an image: ", 's');

  % Load imwrite (if using Octave)
  if ~isempty(ver('Octave'))
   pkg load image
  end

  % Read image
  X = imread(file_path);

  % Turn the image to gray scale if needed
  [~, ~, l] = size(X);
  if(l > 1)
    X = rgb2gray(X);
  end
end
