clear; close all; clc

% Tick clock
tic

%% Parameters
N = 6;                            %The number of observed mixtures
M = 1000;                         %Sample size, i.e.: number of observations

K = 0.1;                          %Slope of zigzag function
na = 8;                           %Number of zigzag oscillations within sample
ns = 5;                           %Number of alternating step function oscillations within sample

finalTime = 40*pi;                %Final sample time (s)
initialTime = 0;                  %Initial sample time (s)

%% Generating Data for ICA
% Create time vector data
timeVector  = initialTime:(finalTime-initialTime)/(M-1):finalTime;

% Create random, cos, sin and fast cos signal
source1     = rand(1, M);                   
source2     = cos(0.25*timeVector);         
source3     = sin(0.1*timeVector);          
source4     = cos(0.7*timeVector);          

% Ziggsack signal
source5 = zeros(1,M);   
periodSource5 = (finalTime-initialTime)/na; 
for i = 1:M
    source5(i) = K*timeVector(i)-floor(timeVector(i)/periodSource5)*K*periodSource5;
end
source5 = source5 - mean(source5);

% PWM signal
source6 = zeros(1,M);  
periodSource6 = (finalTime-initialTime)/ns/2;
for i = 1:M
    if mod(floor(timeVector(i)/periodSource6),2) == 0
        source6(i) = 1;
    else
        source6(i) = -1;
    end    
end

source6 = source6 - mean(source6);

% Create our source matrix. This matrix is what want to find
S = [source1;source2;source3;source4;source5;source6];

% Create an matrix A that going to mix all signals in S, that we calling X
Amix = rand(N,N);                    
X = Amix*S;                                 

figure
plot(timeVector,source1)                    
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('source 1')

figure
plot(timeVector,source2)                    
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('source 2')

figure
plot(timeVector,source3)                    
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('source 3')

figure
plot(timeVector,source4)                    
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('source 4')

figure
plot(timeVector,source5)                   
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('source 5')

figure
plot(timeVector,source6)                    
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('source 6')

figure
plot(timeVector,X);                      
xlabel('time (s)') 
ylabel('Signal Amplitude')
legend('Observed Mixture 1', 'Observed Mixture 2', 'Observed Mixture 3', 'Observed Mixture 4', 'Observed Mixture 5', 'Observed Mixture 6')

% Use ICA to find S from X
S = ica(X);

figure
plot(timeVector, S(1,:))
xlabel('time (s)') 
ylabel('Signal Amplitude') 
legend('Source Estimation 1')

figure
plot(timeVector, S(2,:))
xlabel('time (s)') 
ylabel('Signal Amplitude') 
legend('Source Estimation 2')

figure
plot(timeVector, S(3,:))
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('Source Estimation 3')

figure
plot(timeVector, S(4,:))
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('Source Estimation 4')

figure
plot(timeVector, S(5,:))
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('Source Estimation 5')

figure
plot(timeVector, S(6,:))
xlabel('time (s)')
ylabel('Signal Amplitude') 
legend('Source Estimation 6')

% End clock time and check the difference how long it took
toc
