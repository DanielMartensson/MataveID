% Close all
close all

% Read image
X = imread(fullfile('..', 'data', 'face.jpg'));

% Make image greyscale
if size(X, 3) > 1
  X =  rgb2gray(X);
end

% Compute fast
threshold = 50;
fast_method = 9;
coordintes = mi.fast(X, threshold, fast_method);

% Show
imshow(uint8(X));
hold on
plot(coordintes(:,1), coordintes(:,2), 'r.')
