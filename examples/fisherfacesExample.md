# Fisherfaces
This is a technique that can classify images or raw data from `.pgm` files in the formats `P2` and `P5`.
Fisherfaces was invented in 1997, but this algorithm, I have made some major improvements. First, I'm using Kernel Principal Component Analysis,
instead of regular Principal Component Analysis. Second, I'm using Support Vector Machine instead of K-Nearest Neighbor.

The goal with this algorithm is to return a model:

```matlab
x = model_w*image_vector + model_b
p(x) = 1./(1 + exp(-(A(i)*x(i) + B(i))))
```
Where the `model_w` and `model_b` are matrix and vector from the Support Vector Machine algorithm and `A` and `B` are parameters for the logistic regression. The `image_vector` is your unknown data. It does not necessary must be an image, is can be regular unknwon data as well.

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
5. Train SVM model
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

### Step 4
Not it's time to select the option `1. Collect data`.
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

### Step 5
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

### Step 6
Now we are going to create the model by using Support Vector Machine. I have written the Support Vector Machine algorithm from scratch by using a Quadratic
Programming solver and I'm using Hildreth's QP algorthm. Hildreth's QP-solver was invented in 1957. Notice that it exist also an equivalent C code for the Support Vector Machine and QP-solver in CControl.

This option `5. Train SVM model` wants two parameters.
The `C` hyperparameter tells the SVM optimization how much you want to avoid misclassifying each training example. 
For large values of C, the optimization will choose a smaller-margin hyperplane if that hyperplane does a better job of getting all the training points classified correctly. 
Conversely, a very small value of C will cause the optimizer to look for a larger-margin separating hyperplane, even if that hyperplane misclassifies more points. 
For very tiny values of C, you should get misclassified examples, often even if your training data is linearly separable.

The `lambda` is a regularization parameter. The drawbacks with Hildreth's QP-solver is that it's slow(iterative algorithm) and not so accurate compared to other modern QP-solvers.
The adventage about Hildreth's QP solver is that it can suits embedded systems and easy to use. 
To make Hildreth's QP-solver solve the probelm very quick, just add a small number called `lambda` and it will do the same job as advanced QP-solvers.
Don't have to large regularization parameter `lambda`, it will cause lower accuracy.

```matlab
Enter choice number: 5
Load fisherfaces_projection.mat
Done
Loading fisherfaces_data.mat
Done
What type of C value do you want for SVM: 1
What type of lambda(regularization) value do you want for SVM: 2.5
SVM OK: yes. Accuracy: 1.000000. Class: 1
SVM OK: yes. Accuracy: 1.000000. Class: 2
SVM OK: yes. Accuracy: 1.000000. Class: 3
SVM OK: yes. Accuracy: 1.000000. Class: 4
SVM OK: yes. Accuracy: 1.000000. Class: 5
SVM OK: yes. Accuracy: 1.000000. Class: 6
SVM OK: yes. Accuracy: 1.000000. Class: 7
SVM OK: yes. Accuracy: 1.000000. Class: 8
SVM OK: yes. Accuracy: 1.000000. Class: 9
SVM OK: yes. Accuracy: 1.000000. Class: 10
SVM OK: yes. Accuracy: 1.000000. Class: 11
SVM OK: yes. Accuracy: 1.000000. Class: 12
SVM OK: yes. Accuracy: 1.000000. Class: 13
SVM OK: yes. Accuracy: 1.000000. Class: 14
SVM OK: yes. Accuracy: 1.000000. Class: 15
Done with SVM
Multiply model_w = w * W
x = model_w*image_vector + model_b is our model
p(x) = 1./(1 + exp(-(A(i)*x(i) + B(i))))
The image_vector must be in row-major, not column-major
e.g the image/data you want to classify is going to be in row-wise, not column-wise.
The model will give us a vector x that contains scores.
The scores x are feed into a sigmoid function that computes the propability vector p(x)
The index of the highest propability in vector p(x) is the class ID
Saving model_w, model_b and parameters A and B inside fisherfaces_svm.mat
Done
>>
```

