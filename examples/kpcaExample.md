# Kernel Principal Component Analysis
Kernel Principal Component Analysis can be used for dimension reduction and projection on maximum variance between classes.
Kernel methods make PCA suitable for nonlinear data. Kernels has proven very good results in nonlinear dimension reduction.

```matlab
[P, W] = mi.kpca(X, c, kernel_type, kernel_parameters);
```
## Kernel Principal Component Analysis example

https://github.com/DanielMartensson/MataveID/blob/e4274ae4deae4967aadb6917766a9b04d77b4cd7/examples/kpcaExample.m#L1-L62

![PCA Original Data](../pictures/KPCA_Original_Data.png)

![PCA Result 3D](../pictures/KPCA_Reconstructed_Data.png)
