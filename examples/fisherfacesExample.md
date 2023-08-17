# Fisherfaces
This is a technique that can classify images or raw data from `.pgm` files in the formats `P2` or `P5`.
Fisherfaces was invented in 1997, but this algorithm, I have made some major improvements. First, I'm using Kernel Principal Component Analysis,
instead of regular Principal Component Analysis. Second, I'm building a neural network by using Support Vector Machine instead of only using K-Nearest Neighbor as classifier.

The goal with this algorithm is to return a model:

```matlab
x = sigma(model_w*image_vector + model_b, A, B)
```
Where the `model_w` and `model_b` are matrix and vector for the neural network and `A` and `B` are parameter vectors for the activation function `sigma`.
The index of the highest value of `x` is the class ID of the unknown data `image_vector`. `image_vector` does not necessary must be an image, is can be regular unknwon data as well, as long it's stored inside `.pgm` files of format `P2` or `P5`

To run this algorithm, just type

```matlab
>> mi.fisherfaces
```

## Example Fisherfaces
```matlab
>> mi.fisherfaces
Welcome to Fisherfaces.
This algorithm can classify images or raw data from .pgm files in the formats P2 and P5.
Notice that it exist an equivalent ANSI C code for this inside CControl
What do you want to do?
1. Collect data
2. Train projection matrix
3. Generate PGM data from images
4. Check pooling
5. Train neural network model
6. Remove outliers from collected data
Enter choice number:
```

### Step 1
To begin with, collect images e.g `.png`, `.gif` etc into folders. For example, if you have the `Yale` data set, it contains 11 images per class and the 
total classes are 15. That means you need to have 15 folders with each folders contains 11 images.

### Step 2
Then you run the `mi.fisherfaces`. You will first to use `4. Check pooling`. Pooling is a method that can reduce the size of the image. I recommend that
because it will be much faster to build a model. But don't reduce way to much. The option `4. Check pooling` will give you the orginal image and the 
reduced image so you can compare the settings.

```matlab
Enter choice number: 4
Enter the file path to an image: C:\Users\dmn\GitHub\CControl\src\CControl\Documents\Data\yale\Class 1\centerlight.gif
What pooling method do you want to use?
1. Max pooling
2. Average pooling
3. Shape pooling
Enter choice number:
```

### Step 3
After you have choosen your pooling settings, it's time to generate `.pgm` files. Select the option `3. Generate PGM data from images`.
This will turn all images into `.pgm` files.

```matlab
Enter choice number: 3
Enter the folder path of the sub folders: C:\Users\dmn\GitHub\CControl\src\CControl\Documents\Data\yale
```

### Step 4 (Optional)
Sometimes it can be good to remove outliers from the data because your data is going to be analyzed with Kernel Principal Component Analysis.
Option `6. Remove outliers from collected data` is using `DBscan` to analyze how many outliers there are. If you don't want to remove outliers or does not believe that your data contains
outliers, then you can avoid this step.

```matlab
Enter choice number: 6
Loading fisherfaces_data.mat
Done
Remove outliers with DBscan
Give the minimum epsilon for your data:
```

### Step 5
Now it's time to select the option `1. Collect data`.
This option ask you the desired pooling settings.

```matlab
Enter choice number: 1
Enter the folder path of the sub folders: C:\Users\dmn\GitHub\CControl\src\CControl\Documents\Data\yale
Do you want to use pooling? 1 = Yes, 0 = No: 1
What pooling method do you want to use?
1. Max pooling
2. Average pooling
3. Shape pooling
Enter choice number: 2
What pooling size do you want to use? 8
```

### Step 6
Next step is to select the option `2. Train projection matrix`. This option will ask you about Kernel Principal Component Analysis. 
For `Yale` data set, I like to use `KPCA` value 100. You can use a large number, but not to large so you will get garbage values.
A good rule of thump is not use more than total images you have in your folders.

```matlab
Enter choice number: 2
Loading fisherfaces_data.mat
Done
What kernel type do you want to use?
1. Linear
2. Polynomial
3. Gaussian
4. Exponential
5. Sigmoid
6. RBF
Enter choice number: 6
Enter gamma value: 0.0000001
How many dimensions for KPCA algorithm: 100
Creating kernel
Done
Createing PCA of the kernel
The size of the matrix is 1200x1200. Do you want to apply PCA onto it? 1 = Yes, 0 = No: 1
```

### Step 7
Now we are going to create the neural netowork model by using Support Vector Machine. I have written the Support Vector Machine algorithm from scratch by using a Hildreth Quadratic Programming algorithm. Hildreth's QP-solver was invented in 1957. Notice that it exist also an equivalent ANSI C code for the Support Vector Machine and QP-solver in CControl repository.

This option `5. Train neural network model` wants three parameters.
The `C` hyperparameter tells the SVM optimization how much you want to avoid misclassifying each training example. 
For large values of `C`, the optimization will choose a smaller-margin hyperplane if that hyperplane does a better job of getting all the training points classified correctly. 
Conversely, a very small value of `C` will cause the optimizer to look for a larger-margin separating hyperplane, even if that hyperplane misclassifies more points. 
For very tiny values of `C`, you should get misclassified examples, often even if your training data is linearly separable.

The `lambda` is a regularization parameter. The drawbacks with Hildreth's QP-solver is that it's slow(iterative algorithm) and not so accurate compared to other modern QP-solvers.
The adventage about Hildreth's QP solver is that it can suits embedded systems and easy to use. 
To make Hildreth's QP-solver solve the probelm very quick, just add a small number called `lambda` and it will do the same job as advanced QP-solvers.
Don't have to large regularization parameter `lambda`, it will cause lower accuracy.

The `function type` specifies the activation function You can choose between these functions:
1. Sigmoid: y = 1/(1 + e^(-a*x - b))
2. Tanh: y = (e^(a*x + b) - e^(-a*x - b)))/(e^(a*x + b) + e^(-a*x - b)))
3. ReLU: y = max(0, x)
4. Leaky ReLU: y = max(0.1x, x)

```matlab
Enter choice number: 5
Load fisherfaces_projection.mat
Done
Loading fisherfaces_data.mat
Done
Train a neural network with Support Vector Machine
What type of C value do you want for SVM: 1
What type of lambda(regularization) value do you want for SVM: 2.5
Type in what type of activation function you want to use(sigmoid, tanh, ReLU, Leaky ReLU): ReLU
Neural Network success with accuracy: 1.000000 at class: 1
Neural Network success with accuracy: 1.000000 at class: 2
Neural Network success with accuracy: 1.000000 at class: 3
Neural Network success with accuracy: 1.000000 at class: 4
Neural Network success with accuracy: 1.000000 at class: 5
Neural Network success with accuracy: 1.000000 at class: 6
Neural Network success with accuracy: 1.000000 at class: 7
Neural Network success with accuracy: 1.000000 at class: 8
Neural Network success with accuracy: 1.000000 at class: 9
Neural Network success with accuracy: 1.000000 at class: 10
Neural Network success with accuracy: 1.000000 at class: 11
Neural Network success with accuracy: 1.000000 at class: 12
Neural Network success with accuracy: 1.000000 at class: 13
Neural Network success with accuracy: 1.000000 at class: 14
Neural Network success with accuracy: 1.000000 at class: 15
Saving model_w, model_b, activation parameter vector A, activation parameter vector B and function type inside fisherf
aces_model.mat
Done
>>
```

