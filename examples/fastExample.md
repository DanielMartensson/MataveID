# FAST
Use FAST if you want to find corners inside an image. There is also an equivalent C-code FAST algorithm inside the CControl repository.

```matlab
[corners, scores] = mi.fast(image, threshold, fast_method);
```

## Example

https://github.com/DanielMartensson/MataveID/blob/af13657898163b9bd6554e7befa9880b683e8813/examples/fastExample.m#L1-L22

## Result
![FAST Result](../pictures/FAST_Result.png)
