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
There are lots of different algorithms, even if they look very similar. I have been using them all and lots of them are experimental. Here is my list of choise:

```
* OKID - Use this to begin with. It's a good and easy algorithm that suits most cases. 
* MOESP - If you got noise inside your measurement. This is a good algorithm to choose. 
* N4SID - If MOESP did not solve your problem. You can try this one. Requires more data. 
* TFEST - Standard transferfunction estimation using least squares. Easy to use.
* RLS - Recursive Least Square - Also estimates a Kalman Gain matrix without any further knowledge about noise.
* ARX - If you need a transfer function with a noise model. This is a basic system idenfication method.
* ARMAX - If you need a transfer function for stochastical systems
* SPA - If you got a signal with lots of noise, then you can seperate all noise and see each noise signal. Very clever tool. I like this function.
* SMOOTHING - Here you can write your own signal by using the mouse clicker.
* MOAVG - Simple filtering
* MOAVG2 - This is an algorithm written by me. I normaly use this before MOAVG, but MOAVG is faster because it used internal C++ routines. 

Remeber that MataveControl have good tools for finish the model in system identification, such as referencegain.m function.
It will add a reference gain to the model for better tracking.
```

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

