# MataveID V16.0.1
MataveID is a basic system identification toolbox for both GNU Octave and MATLAB®. MataveID is based on the power of linear algebra and the library is easy to use. MataveID using the classical realization and polynomal theories to identify state space models from data. There are lots of subspace methods in the "old" folder and the reason why I'm not using these files is because they can't handle noise quite well. 

I'm building this library because I feel that the commercial libraries are just for theoretical experiments. I'm focusing on real practice and solving real world problems. 

# TODO

| Function  | Status | Comment | 
| ------------- | ------------- | ------------------- |
| `rpca.m` | Complete | Nothing to do here |
| `filtfilt.m` | Complete | Nothing to do here |
| `pf.m` | Complete | Nothing to do here |
| `spa.m` | Complete | Nothing to do here |
| `arx.m` | Complete | Nothing to do here |
| `oe.m` | Complete | Nothing to do here |
| `armax.m` | Complete | Nothing to do here |
| `lsvm.m`  | Complete | Nothing to do here |
| `cca.m`  | Almost complete  | Returns kalman gain matrix `K`, need to have a practical example |
| `rls.m`  | Almost complete  | Returns kalman gain matrix `K`, need to have a better practical example |
| `eradc.m` | Almost complete | Added a kalman filter, need to have a pratical example |
| `n4sid.m` | Almost complete | Added a kalman filter, need to have a better pratical example |
| `moesp.m` | Almost complete | Added a kalman filter, need to have a pratical example |
| `kmeans.m` | Almost complete | Need to have a pratical example |
| `pca.m` | Almost complete | Need to find a practical example |
| `lda.m` | Almost complete | Need to find a practical example |
| `ica.m` | Almost complete | Need to find a practical example |
| `sra.m` | Almost complete | Upload measurement sensor system |
| `bj.m` | Almost complete | Find a pratical example |
| `sindy.m` | Complete | Nothing to do here |
| `ocid.m` | Ongoing | Find a pratical example and test it, test the observer with `ocid.m` |
| `sr_ukf_parameter_estimation.m` | Ongoing | Find a practical example for a hydraulic orifice |
| `sr_ukf_state_estimation.m` | Ongoing | Use with `sindy.m` and a pratical example |
| `ortjiop.m` | Ongoing | Find a practical example |
| `idbode.m` | Ongoing | Find a practical example |
| `ica.m` | Ongoing | Find a practical example |
| `lsvm.m` | Ongoing | Find a practical example with image classification and PCA + LDA |
| `okid.m` | Not created yet | Create the `okid.m` file and make sure it is robust against noise and also returns `K` matrix. Borrow code from the `old` folder. |
| `dnn.m` | Not created yet | Planning to include a basic deep neural network for modeling nonlinear dynamics or other types of classifications |


# Functions and its purpose
- ERA-DC for mechanical damped systems in the time plane
- SINDY for multivariable abritary nonlinear systems
- RLS for all kind of arbitary single input and single output systems
- OCID for closed loop identification, observer identification and controller identification
- ORTJIOP for stochastic closed loop, plant and controller identification
- FILTFILT for low pass filtering without phase delay
- SPA for spectral analysis
- IDBODE for mechanical damped systems in the frequency plane
- RPCA for reducing noise from data
- PCA for dimension reduction on maximum variance
- LDA for dimension reduction on maximum distance
- ICA for separating signals so they are independent from each other
- SR-UKF-Parameter-Estimation for finding parameters from an very complex system of equation if data is available
- SR-UKF-State-Estimation for filtering noise and estimate the state of a system
- Nonlinear SVM for C-code classification of data for CControl
- Linear SVM for generate a 1xN matrix + bias variable for prediction
- N4SID for regular linear state space systems
- MOESP for regular linear state space systems
- CCA for linear stochastic state space systems
- SRA for stochastic model identification
- PF for particle filter for non-gaussian state estimation filtering
- BJ for estimate system model and disturbance model
- KMEANS for identify clusters

# Papers:
MataveID contains realization identification, polynomal algorithms and subspace algorithms. They can be quite hard to understand, so I highly recommend to read papers in the "reports" folder about the algorithms if you want to understand how they work, or read the literature.

# Literature:
I have been using these books for creating the `.m` files. All these books have different audience. Some techniques are meant for researchers and some are meant for practical engineering.

### Applied System Identification
This book include techniques for linear mechanical systems such as vibrating beams, damping, structural mechanics etc. These techniques comes from NASA and the techniques are created by `Jer-Nan Juang`. This is a very practical book. The book uses the so called realization theory methods for identify dynamical models from data. 

Advantages:
 - Easy to read and very practical
 - Include mechanical model buildning
 - Include impulse, frequency, stochastic, closed loop and recursive identification
 - These techniques are applied onto Hubble Telescope, Space Shuttle Discovery and Galileo spacecraft
 
Disadvantages:
 - Do not include nonlinear system identification and subspace methods
 - Do not include filtering
 - MATLAB files from this book is export controlled from NASA = Difficult to download
 - This book is not produced anymore. I have the PDF.

![Applied System Identification](pictures/AppliedSystemIdentification.jpeg)

### System Modeling & Identification
This book covering techniques for all types of systems, linear and nonlinear, but it's more a general book for system identfication. `Professor Rolf Johansson` book contains lots of practice, but also theory as well. More theory and less practice compared to `Applied System Identification` from `Jer-Nan Juang`. This book uses both the realization theory methods and subspace methods for identify dynamical systems from data. Also this book includes filters as well such as Uncented Kalman Filter. Can be purchased from https://kfsab.se/sortiment/system-modeling-and-identification/ 

Advantages:
 - Easy to read and somtimes practical
 - Include filtering, statistics and other types of modeling techniques
 - Include impulse, frequency, stochastic, closed loop, nonlinear and recursive identification
 - Include both realization theory, subspace and nonlinear system identification methods
 
Disadvantages:
 - Do not include closed loop identification
 - Some methods are difficult to understand how to apply with MATLAB-code. Typical univerity literature for students

![Rolf Johanssons Book](pictures/RolfJohanssonsBok.jpg)

### Subspace Methods For System Identification
This book include techniques for all types of linear systems. It's a general book of linear system identification. The advantages of this book is that it include modern system identification techniques. The disadvantages about this book is that it contains only theory and no practice, but `Professor Tohru Katayama`, have made a great work for collecting all these subspace methods. Use this book if you want to have knowledge about the best subspace identification methods.

Advantages:
 - Include MATLAB code examples and lots of step by step examples
 - Include stochastic and closed identification
 - Include the latest methods for linear system identification
 - Include both realization theory and subspace system identification methods
 
Disadvantages:
 - Difficult to read and understand
 - Does not include impulse, frequency and nonlinear identification
 - Does not include filtering, statistics and other types of modeling techniques

![subspace methods for system identification](pictures/subspace_methods_for_system_identification.jpg)

### Adaptive Control
This book is only for adaptive control. But there is one algorithm that are very useful - Recursive Least Squares. This is a very pratical book for applied adaptive control. It's uses the legacy SISO adaptive techniques such as pole placement, Self Tuning Regulator(STR) and Model Reference Adaptive Systems(MRAS) combined with Recursive Least Squares(RLS). If you wonder why only SISO and not MIMO, it's because adaptive control is very difficult to apply in practice and create a reliable controller for all types of systems. The more difficult problem is to solve, the more simplier technique need to be used.

Advantages:
 - The authors of the book explains which chapters are for pratcial engineering and theoretical researchers
 - Easy to read 
 - Include both advanced and simple methods depending on which type of problem to solve

Disadvantages:
 - Only one system identification algorithm is taught
 - Only SISO model are applied
 - This book is made for adaptive control and have only one chapter that contains system identification

![Adaptive control](pictures/Adaptive_control.png)

Examples
All the examples are contained in the example folder. For each example, there is at least a Markdown file (.md) and a m-file (.m).

[Examples](examples/)


# Install
To install MataveID, download the folder "matave" and place it where you want it. Then the following code need to be written inside of the terminal of your MATLAB® or GNU Octave program. 

```matlab
path('path/to/the/folder/matave', path)
savepath
```
Example of a typical path.

```matlab
path('C:\Users\dmn\Documents\Octave\matave\', path)
savepath
```

Package requriments: 

 - [MataveControl](https://github.com/DanielMartensson/matavecontrol) package.

# Update
Write this inside the terminal. Then MataveID is going to download new .m files to MataveID from GitHub

```matlab
mi.updatemataveid
```
