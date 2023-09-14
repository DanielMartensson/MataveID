# Hough Transform
Use this algorithm if you want to find lines inside an edge image. Important that the image needs to be an edge image. 

```matlab
[N, K, M, R, T] = mi.hough(X, p, epsilon, min_pts);
```

## Hough Transform example

Assume that we have road that we want to track by writing two parallell lines that follows the road and we want to avoid everything else.

https://github.com/DanielMartensson/MataveID/blob/0152b6ba7be0c80007987bb68f0c88b9e7e8b499/examples/houghExample.m#L1-L29

![Hough Result](../pictures/Hough_Result.png)
