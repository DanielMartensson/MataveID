# Mataveid V1.0
Mataveid is a basic system identification toolbox for both GNU Octave and MATLAB®. Mataveid is based on the power of linear algebra and the library is easy to use. Subspace identification(under development), realization theory and least square are main focus in this project.

# Litterature: 
* System Modeling & Identification, Rolf Johansson, 2nd 2017, Lund University, Sverige, ISBN 0-13-482308-7

# Reports:
* Recursive Form of the Eigensystem Realization Algorithm for System Identification, Jer-Nan Juang, NASA Langley Research Center, Hampton, Virginia, 1989


# Typical use

User input when using Eigensystem Realization Algorithm

![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/Sk%C3%A4rmbild%20fr%C3%A5n%202017-12-04%2019-41-18.png)

Model reduction to reduce noise from the model

![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/Sk%C3%A4rmbild%20fr%C3%A5n%202017-12-04%2019-20-27.png)

The result

![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/Sk%C3%A4rmbild%20fr%C3%A5n%202017-12-04%2019-36-13.png)

Estimating a linear function
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/Sk%C3%A4rmbild%20fr%C3%A5n%202017-12-04%2019-48-02.png)

The result
![alt text](https://github.com/DanielMartensson/mataveid/blob/master/pictures/Sk%C3%A4rmbild%20fr%C3%A5n%202017-12-04%2019-50-03.png)

# Install
To install Matavecontrol, download the folder "sourcecode" and place it where you want it. Then the following code need to be written in the terminal of your MATLAB® or GNU Octave program.

```matlab
path('path/to/the/sourcecode/folder/where/all/mataveid/files/are', path)
savepath
```

# Requirements 
* Installation of Matavecontrol package https://github.com/DanielMartensson/matavecontrol

