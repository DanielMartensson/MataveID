# Density-based spatial clustering of applications with noise

This is a cluster algorithm that can identify the amount of clusters. 
This algorithm requries two tuning parameters, `epsilon` and `min_pts`, which stands for `radius` and `minimum points`.

It exist an equivalent C-code dbscan inside CControl repository.

```matlab
[idx] = mi.dbscan(X, epsilon, min_pts);
```

# Example Density-based spatial clustering of applications with noise

https://github.com/DanielMartensson/MataveID/blob/7e1b828a4782826489139ea46defd12bec4c7c38/examples/dbscanExample.m#L1-L110

## Results
![Box Jenkins Results](../pictures/DBSCAN_Result.png)
