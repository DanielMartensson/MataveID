% Load the data
file = fullfile('..','data','Measurement_WellerToJBC.csv');
X = csvread(file);
setpoint = X(:, 2);
temperature = X(:, 3);

% Fix some corrupted data points
setpoint(setpoint < 0) = [];
for i = 2:length(temperature)
  if(temperature(i) < 50)
    temperature(i) = temperature(i - 1);
  end
end

% Same length as temperature
setpoint(end + 1) = setpoint(end);

% Create first order model
sys = mc.ss(0, 9.9154e-01, 4.8969e-03);

% Disturbance covariance
Q = 0.05;

% Noise covariance
R = 1;

% Kalman filter
xhat = mi.kf(sys, setpoint', temperature', Q, R);

% Plot
plot(xhat);
hold on
plot(temperature);
legend('Estimated', 'Real');
grid on
