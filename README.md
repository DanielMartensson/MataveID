# Mataveid V4.5
Mataveid is a basic system identification toolbox for both GNU Octave and MATLAB®. Mataveid is based on the power of linear algebra and the library is easy to use. Subspace identification, realization theory and least square polynomial models are main focus in this project.

Please check my IoT-software for loging values in real time via USB-port and over the internet. Perfect for system identification.
https://github.com/DanielMartensson/JLogger

# Neural Networks
If you want to estimate neural networks for nonlinear models, have a look at Deeplearning2C. It's a Java application that generates neural network in C code.

https://github.com/DanielMartensson/Deeplearning2C

# Reports:

Mataveid contains subspace identification and realization identification algorithms. They can be quite hard to understand, compared to ARX, ARMAX, OE, TF models, so I highly recommend to read reports about the subspace identification and realization identification algorithm, to understand how the MATLAB/Octave functions code are written. The reports can be found in the folder "reports".

# What should I use?
There are lots of different algorithms, even if they look very similar. All of them works, but there are some that are more for practical use, rather than scientific research. I have been using them all and lots of them are experimental. Here is my list of choise of algorithms that are used in control engineering and not control theory.

### OKID - Observer Kalman Filter Identification
Wants random input and output data. It will give back a discrete state space model and a kalman gain matrix.
This algoritm is very good if you got some noise in the measurements. Can handle both MIMO and SISO data. Used in space engineering.
```
[sysd, K] = okid(u, y, sampleTime, delay, regularization, systemorder)
```

### RLS - Recursive Least Squares
Wants random input and output data. It will give back a ARMAX model or a ARX model, depending on the order of zeros-numerator parameter 'nze' for the C-polynomial, and of course a discrete state space model with kalman gain matrix. This algoritm is very good if you got some noise in the measurements. Can only handle SISO data but it a very fast and
low memory consuming algorithm. Used in adaptive systems.
```
[Gd, Hd, sysd, K] = rls(u, y, np, nz, nze, sampleTime, delay, forgetting);
```

### ERA-DC - Eigensystem Realization Algorithm Data Correlations
Wants impulse response data. Will give back a discrete state space model. This algorithm is good for structural mechanics. This algorithm can handle noise.
Can handle both MIMO and SISO data. 
```
[sysd] = eradc(g, nu, sampleTime, delay, systemorder);
```
!Need some more work on MIMO case for ERA-DC. MIMO still works, but I assume that there are some error indexing in the hankel matrices. If you want to help, please read EigensystemRealization.pdf file in the reports folder!

### SSFD - State Space Frequency Domain
Wants frequency response data. Will give back a state space model and a kalman gain matrix. This algorithm is good for fast mechanical systems such as servo systems. 

- Under development

### OCID - Observer Controller Identification
Wants random input and output data.  It will give back a discrete state space model and a kalman gain matrix and a control law. 

- Under development

# Starting

Always start with help command of each function

```matlab
>> help era
'era' is a function from the file /home/hp/Dokument/Reglerteknik/mataveid/era.m

 Eigensystem Realization Algorithm
 Input: g(markov parameters), nu(number of inputs), sampleTime, delay(optional)
 Output: sysd(Discrete state space model)
 Example 1: [sysd] = era(g, nu, sampleTime, delay);
 Author: Daniel Mårtensson, November 2017

>>
```

# Typical use
# Ho-Kalman algorithm 
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/hokalman.png)
# Eigensystem Realization Algorithm
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/era.png)
# Eigensystem Realization Algorithm - Data Correlation
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/eradc.png)
# Step Based Realization
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/sbr.png)
# Observer/Kalman Filter Identification
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/okid.png)
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/okid2.png)
# Multivariable Subspace Identification
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/moesp.png)
# Past Input Multivariable Subspace Identification
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/pimoesp.png)
# Numerical Algorithms For Subspace State Space System IDentification
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/n4sid.png)
# Multivariable Numerical Algorithms For Subspace State Space System IDentification
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/MIMOn4sid.png)
# Arbitrary Subspace Algorithm  
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/asa.png)
# Orthogonal Decomposition
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/ort.png)
# Autoregressive Exogenous Model
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/arx.png)
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/arx2.png)
# Transfer function estimation
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/arxtf.png)
# Recursive Least Square - Perfect to convert to C code for embedded systems
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/RecursiveLeastSquare.png)
# Autoregressive–moving-average
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/armax.png)
# Spectral Analysis
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/spa.png)
# Smoothing
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/smoothing.png)
# Moving average
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/movingaverage.png)
# Linear Least Square best fit
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/leastsquare.png)
# Moving average 2
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/moavg2.png)


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

