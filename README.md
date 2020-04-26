# Mataveid V6.0
Mataveid is a basic system identification toolbox for both GNU Octave and MATLAB®. Mataveid is based on the power of linear algebra and the library is easy to use. Mataveid using the classical realization and polynomal theories to identify state space models from 
data. There are lots of subspace methods in the "old" folder and the reason why I'm not using these files is because they can't handle noise. 

# Papers:

Mataveid contains realization identification and polynomal algorithms. They can be quite hard to understand, so I highly recommend to read papers in the "reports" folder about the realization identification algorithms if you want to understand how they work. 

### OKID - Observer Kalman Filter Identification
OKID is an algoritm that creates the impulse makrov parameter response from data for identify a state space model and also a kalman filter gain matrix. Use this if you got regular data from a dynamical system. This algorithm can handle both SISO and MISO. OKID have it's orgin from Hubble Telescope at NASA. This algorithm was invented 1991.

Use this algorithm if you got regular data from a open loop system.

```matlab
[sysd, K] = okid(u, y, sampleTime, delay, regularization, systemorder);
```

### Example OKID

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/OKID_System.png)

```matlab
%% Parameters
J = 0.01;
b = 0.1;
K = 0.01;
R = 1;
L = 0.5;

% Matrix A
A = [0 1  0  0; 
    -K*R*L -(J+K+R*2) 0  1; 
     0 0  0  1;
     0 1 -(b+J) -5*(J+R*2)];
  
% Matrix B
B = [0 ; 
     0 ; 
     0 ; 
     1 ];
  
% Matrix C
C = [0 0 0 1];
 
%% Model 
motor_ss = ss(0, A, B, C);

%% Input and time
t = linspace(0, 20, 1000);
u = [linspace(-1, 11, 100) linspace(-11, 11, 100) linspace(-11, 4, 100) linspace(-3, 8, 100) linspace(2, -10, 100) linspace(6, -9, 100) linspace(4, 1, 100) linspace(0, 0, 100) linspace(-10, 17, 100) linspace(-30, 0, 100)];

%% Simulation
y = lsim(motor_ss, u, t);

%% Add 10% noise
load v
for i = 1:length(y)-1
  noiseSigma = 0.10*y(:, i);
  noise = noiseSigma*v(i); % v = noise, 1000 samples -1 to 1
  y(:, i) = y(:, i) + noise;
end


%% Identification 
regularization = 831;
modelorder = 3;
[sysd, K] = okid(u, y, t(2) - t(1), 0, regularization, modelorder);
close
    
%% Validation
yt = lsim(sysd, u, t);
close
    
%% Check
plot(t, y, t, yt(:, 1:2:end))
legend("Data 1", "Identified 1", 'location', 'southwest')
grid on
```
![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/OKID_Result.png)

### RLS - Recursive Least Squares
RLS is an algorithm that creates a state space model from regular data. Here you can select if you want to estimate an ARX model or an ARMAX model, depending on the number of zeros in the polynomal "nze". Select number of error-zeros-polynomal "nze" to 1, and you will get a ARX model or select "nze" equal to model poles "np", you will get an ARMAX model that also includes a kalman gain matrix K. I recommending that. This algorithm can handle data with high noise, but you will only get a SISO model from it. This algorithm was invented 1821 by Gauss, but it was until 1950 when it got its attention in adaptive control.

Use this algorithm if you have regular data from a open loop system and you want to apply that algorithm into embedded system that have low RAM and low flash memory. RLS is very suitable for system that have a lack of memory. 

```matlab
[Gd, Hd, sysd, K] = rls(u, y, np, nz, nze, sampleTime, delay, forgetting);
```

### Example RLS

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/RLS_System.png)

```matlab
%% Parameters
m = 1000; % Mass kg
b = 50; % Friction 

A = -b/m;
B = 1/m;
C = 1;
D = 0; % Does not need. ss function will auto generate D
delay = 0;

%% Model
cruise_ss = ss(delay,A,B,C,D);

%% Input and time
t = linspace(0, 20, 1000);
u = [linspace(5, -11, 100) linspace(7, 3, 100) linspace(-6, 9, 100) linspace(-7, 1, 100) linspace(2, 0, 100) linspace(6, -9, 100) linspace(4, 1, 100) linspace(0, 0, 100) linspace(10, 17, 100) linspace(-30, 0, 100)];

%% Simulation
y = lsim(cruise_ss, u, t);

%% Add 20% noise
load v
for i = 1:length(y)
  noiseSigma = 0.20*y(i);
  noise = noiseSigma*v(i); % v = noise, 1000 samples -1 to 1
  y(i) = y(i) + noise;
end

%% Identification - ARMAX  
np = 5; % Number of poles for A polynomial
nz = 5; % Number of zeros for B polynomial
nze = np % Numer of zeros for C polynomial
forgetting = 0.99;
[Gd, Hd, sysd, K] = rls(u, y, np, nz, nze, t(2) - t(1), delay, forgetting); % K will be included inside sysd
close
    
%% Validation
yt = lsim(Gd, u, t);
close
    
%% Check
plot(t, y, t, yt(:, 1:2:end))
legend("Data", "Identified", 'location', 'northwest')
grid on
````

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/RLS_Result.png)

### ERA/DC - Eigensystem Realization Algorithm Data Correlations
ERA/DC was invented 1987 and is a successor from ERA, that was invented 1985 at NASA. The difference between ERA/DC and ERA is that ERA/DC can handle noise much better than ERA. But both algorihtm works as the same. ERA/DC want an impulse response. e.g called markov parameters. You will get a state space model from this algorithm. This algorithm can handle both SISO and MISO data.

Use this algorithm if you got impulse data from e.g structural mechanics.

```matlab
[sysd] = eradc(g, sampleTime, delay, systemorder);
```
### Example ERA/DC

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/ERADC_System.png)

```matlab
%% Parameters
m1 = 2.3;
m2 = 3.1;
k1 = 8.5;
k2 = 5.1;
b1 = 3.3;
b2 = 5.1;

A=[0                 1   0                                              0
  -(b1*b2)/(m1*m2)   0   ((b1/m1)*((b1/m1)+(b1/m2)+(b2/m2)))-(k1/m1)   -(b1/m1)
   b2/m2             0  -((b1/m1)+(b1/m2)+(b2/m2))                      1
   k2/m2             0  -((k1/m1)+(k1/m2)+(k2/m2))                      0];
B=[0;                 
   1/m1;              
   0;                
   (1/m1)+(1/m2)];
C=[0 0 1 0];
D=[0];
delay = 0;

%% Model
buss = ss(delay,A,B,C,D);

%% Simulation
[g, t] = impulse(buss, 10);

%% Add 15% noise
load v
for i = 1:length(g)-1
  noiseSigma = 0.15*g(i);
  noise = noiseSigma*v(i); % v = noise, 1000 samples -1 to 1
  g(i) = g(i) + noise;
end

%% Identification  
systemorder = 4;
[sysd] = eradc(g, t(2) - t(1), delay, systemorder);
    
%% Validation
gt = impulse(sysd, 10);
close
    
%% Check
plot(t, g, t, gt(:, 1:2:end))
legend("Data", "Identified", 'location', 'northwest')
grid on
```

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/ERADC_Result.png)

### SSFD - State Space Frequency Domain
This is a very popular state space algorithm. The labeling for the name is quite wrong, because this algorithm cannot only handle frequency response data. This algorithm can handle noisy MIMO and SISO data as well. This algorihtm have its orgin from Ho-Kalman around 1966 and I have modify it. The idea is the same. Create a MIMO or SISO transfer function and estimate its impulse markov parameter from its polynomials. I have modify it by using RLS to create a SISO transfer function for every signal and then find its 
markov parameters. Then I have used ERA/DC for identify the MIMO or SISO state space model. 

Use this algorithm if you got noisy MIMO data.

```matlab
[sysd] = ssfd(u, y, sampleTime, modelorderTF, delay, forgetting, systemorder);
```

### SSFD Example

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/SSFD_System.png)

```matlab
%% Parameters
Dm = 30;
beta = 1*10^2;
V1 = 10;
V2 = 10;
BL = 3000;
Bm = 10;
JL = 1000;
Jm = 10;
Ps = 100;

%% State space for open valve
A = [0 1;
     0 -(BL+Bm)/(JL+Jm)];
     
B = [0 0;
     (Ps*Dm)/(JL+Jm) -(1)/(JL+Jm)];

%% Model
hydraulicMotor = ss(delay,A,B);

%% Input and time
t = linspace(0, 20, 1000);
u = [linspace(5, -11, 100) linspace(7, 3, 100) linspace(-6, 9, 100) linspace(-7, 1, 100) linspace(2, 0, 100) linspace(6, -9, 100) linspace(4, 1, 100) linspace(0, 0, 100) linspace(10, 17, 100) linspace(-30, 0, 100)];
u = [u; 5*u]; % MIMO 

%% Simulation
y = lsim(hydraulicMotor, u, t);

%% Add 5% noise
load v
for i = 1:length(y)
  noiseSigma = 0.05*y(:, i);
  noise = noiseSigma*v(i); % v = noise, 1000 samples -1 to 1
  y(:, i) = y(:, i) + noise;
end

%% Identification  
systemorder = 6;
modelorderTF = 9;
forgetting = 1;
[sysd] = ssfd(u, y, t(2) - t(1), modelorderTF, delay, forgetting, systemorder);
    
%% Validation
yt = lsim(sysd, u, t);
close
    
%% Check
plot(t, y, t, yt(:, 1:2:end))
legend("Data 1", "Data 1", "Identified 1", "Identified 2", 'location', 'northwest')
grid on
```

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/SSFD_Result.png)

### OCID - Observer Controller Identification
This is an extention from OKID. The idea is the same, but OCID creates a LQR contol law as well. This algorithm works only for closed loop data. It have its orgin from NASA around 1992 when NASA wanted to identify a observer, model and a LQR control law from closed loop data that comes from an actively controlled aircraft wing in a wind tunnel at NASA Langley Research Center. This algorithm works for both SISO and MIMO models.

Use this algorithm if you want to extract a LQR control law, kalman observer and model from a running dynamical system. Or if your open loop system is unstable and it requries some kind of feedback to stabilize it. Then OCID is the perfect choice.

```matlab
[sysd, K, L] = ocid(r, uf, y, sampleTime, delay, regularization, systemorder);
```

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/OCID_System.png)

### OCID Example

```matlab
%% Matrix A
A = [0 1  0  0; 
    -7 -5 0  1; 
     0 0  0  1;
     0 1 -8 -5];
  
%% Matrix B
B = [0 0; 
     1 0; 
     0 0; 
     0 1];
  
%% Matrix C
C = [1 0 0 0; 
     0 0 0 1];
  
%% Model and signals
sys = ss(0, A, B, C);
t = linspace(0, 20, 1000);
r = [linspace(5, -11, 100) linspace(7, 3, 100) linspace(-6, 9, 100) linspace(-7, 1, 100) linspace(2, 0, 100) linspace(6, -9, 100) linspace(4, 1, 100) linspace(0, 0, 100) linspace(10, 17, 100) linspace(-30, 0, 100)];
r = [r;2*r]; % MIMO
  
%% Feedback
Q = sys.C'*sys.C;
R = [1 4; 1 5];
L = lqr(sys, Q, R);
[feedbacksys] = reg(sys, L);
yf = lsim(feedbacksys, r, t);

%% Add 10% noise
load v
for i = 1:length(yf)
  noiseSigma = 0.10*yf(:, i);
  noise = noiseSigma*v(i); % v = noise, 1000 samples -1 to 1
  yf(:, i) = yf(:, i) + noise;
end

%% Identification  
uf = yf(3:4, :); % Input feedback signals
y = yf(1:2, :); % Output feedback signals
regularization = 600;
modelorder = 4;
[sysd, K, L] = ocid(r, uf, y, t(2) - t(1), delay, regularization, modelorder);
    
%% Validation
u = -uf + r; % Input signal %u = -Lx + r = -uf + r
yt = lsim(sysd, u, t);
close
    
%% Check
plot(t, yt(1:2, 1:2:end), t, yf(1:2, :))
legend("Identified 1", "Identified 2", "Data 1", "Data 2", 'location', 'northwest')
grid on
```

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/OCID_Result.png)

### IDBode - Identification Bode
This plots a bode diagram from measurement data. It can be very interesting to see how the amplitudes between input and output behaves over frequencies. This can be used to confirm if your estimated model is good or bad by using the `bode` command from Matavecontrol and compare it with idebode.

```matlab
idbode(u, y, w);
```

### IDBode Example

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/IDBODE_System.png)

```matlab
%% Model of a mass spring damper system
M = 5; % Kg
K = 100; % Nm/m
b = 52; % Nm/s^2
G = tf([1], [M b K]);

%% Frequency response
t = linspace(0.0, 50, 3000);
w = linspace(0, 100, 3000);
u = 10*sin(2*pi*w.*t);

%% Simulation
y = lsim(G, u, t);
close

%% Identify bode diagram
idbode(u, y, w);

%% Check
bode(G);
```

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/IDBODE_Result.png)

### SPA - Spectral Analysis
This plots all the amplitudes from noisy data over its frequencies. Very good to see what type of noise or signals you have. With this, you can determine what the real frequencies and amplitudes are and therefore you can create your filtered frequency response that are clean.

```matlab
[amp, wout] = spa(y, t);
```

### SPA Example

Assume that we are using the previous example with different parameters.

```matlab
%% Model of a mass spring damper system
M = 1; % Kg
K = 500; % Nm/m
b = 3; % Nm/s^2
G = tf([1], [M b K]);

%% Frequency response
t = linspace(0.0, 100, 30000);
u1 = 10*sin(2*pi*5.*t); % 5 Hz
u2 = 10*sin(2*pi*10.*t); % 10 Hz
u3 = 10*sin(2*pi*20.*t); % 20 Hz
u4 = 10*sin(2*pi*8.*t); % 8 Hz
u = u1 + u2 + u3 + u4;

%% Simulation
y = lsim(G, u, t);
figure

%% Noise
y = y + 0.001*randn(1, 30000); 

%% Identify what frequencies we had!
spa(y, t);
```

![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/SPA_Result.png)

### Filtfilt2 - Zero Phase Filter
This filter away noise with a good old low pass filter that are being runned twice. Filtfilt2 is equal to the famous function filtfilt, but this is a regular .m file and not a C/C++ subroutine. Easy to use and recommended. 

```matlab
[y] = filtfilt2(y, t, K);
```

### Filtfilt2 Example

We are using the previous example here as well.

```matlab
%% Model of a mass spring damper system
M = 1; % Kg
K = 500; % Nm/m
b = 3; % Nm/s^2
G = tf([1], [M b K]);

%% Input signal
t = linspace(0.0, 100, 3000);
u = 10*sin(t);

%% Simulation
y = lsim(G, u, t);

%% Add 10% noise
load v
for i = 1:length(y)
  noiseSigma = 0.10*y(i);
  noise = noiseSigma*v(i); % v = noise, 1000 samples -1 to 1
  y(i) = y(i) + noise;
end

%% Filter away the noise
lowpass = 0.2;
[yf] = filtfilt2(y, t, lowpass);

%% Check
plot(t, yf, t, y);
legend("Filtered", "Noisy");
```
![a](https://raw.githubusercontent.com/DanielMartensson/Mataveid/master/pictures/FILTFILT2_Result.png)


# Install
To install Mataveid, download the folder "sourcecode" and place it where you want it. Then the following code need to be written in the terminal of your MATLAB® or GNU Octave program.

```matlab
path('path/to/the/sourcecode/folder/where/all/matave/files/are/mataveid', path)
savepath
```

Example:
```matlab
path('/home/hp/Dokument/Reglerteknik/mataveid', path)
savepath
```

Important! All the .m files need to be inside the folder mataveid if you want the update function to work.

# Update
Write this inside the terminal. Then Mataveid is going to download new .m files to mataveid from GitHub

```matlab
updatemataveid
```

# Requirements 
* Installation of Matavecontrol package https://github.com/DanielMartensson/matavecontrol

