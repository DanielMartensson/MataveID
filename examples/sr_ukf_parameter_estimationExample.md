# Square Root Uncented Kalman Filter for parameter estimation
This is Uncented Kalman Filter that using cholesky update method (more stable), instead of cholesky decomposition. This algorithm can estimate parameters to very a complex function if data is available. This method is reqursive and there is a C code version in CControl as well. Use this when you need to estimate parameters to a function if you have data that are generated from that function. It can be for example an object that you have measured data and you know the mathematical formula for that object. Use the measured data with this algorithm and find the parameters for the formula.

```matlab
[Sw, what] = mi.sr_ukf_parameter_estimation(d, what, Re, x, G, lambda_rls, Sw, alpha, beta, L);
```

## Square Root Uncented Kalman Filter for parameter estimation example
https://github.com/DanielMartensson/MataveID/blob/2014b74a0863729b43e0ee02ecdcd4fcbc06b26b/examples/sr_ukf_parameter_estimationExample.m#L1C1-L62

![SR UKF parameter estimation](../pictures/SR_UKF_parameter_estimation.png)