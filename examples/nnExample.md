# NN - Neural Network
This generates a neural network back and an activation function.
This Neural Network is tranied by Support Vector Machine.

```matlab
[weight, bias, activation_function] = mi.nn(data, class_id, C, lambda);
```

## Example
Here I'm using Fisher's Irish dataset to train a neural network.
https://github.com/DanielMartensson/MataveID/blob/30c4904c85bb14352724aca1827da023d52950b5/examples/nnExample.m#L1-L29

Output:
```matlab
Training: Neural Network success with accuracy: 1.000000 at class: 1
Training: Neural Network success with accuracy: 0.733333 at class: 2
Training: Neural Network success with accuracy: 0.986667 at class: 3
The accuracy of this model is: 96.6667
```
