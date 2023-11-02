% Remove
clear 
close all
clc

% Create data
t = linspace(0, 3*pi, 200)';
data = [40 + 10*randn(200,3);
        50 + 5*sin(t) + 5*t, 10*randn(200, 1), 5*sqrt(t.^2);
        -20 + 23*rand(300, 3)];

% Amount of clusters
K = 3;

% K-means clustering
[idx, C, success] = mi.kmeans(data, K);

% Check
if(success)
  disp('K-means clustering success!');
else
  disp('You need to try with another K-value');
end

% Plot cluster
figure;
scatter3(data(:,1), data(:,2), data(:,3), 10, idx, 'filled');
hold on;
scatter3(C(:,1), C(:,2), C(:,3), 50, 'r', 'filled');
title('K-means clustering', 'FontSize', 20);
xlabel('x', 'FontSize', 20);
ylabel('y', 'FontSize', 20);
zlabel('z', 'FontSize', 20);
