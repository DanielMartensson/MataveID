# Local Binary Pattern
Use LBP if you want to find a binary pattern inside of a matrix, or an image `X` around a pixel `P = X(y, x)`

```matlab
[descriptor] = mi.lbp(X, x, y, radius, init_angle, lbp_bit);
```

## Example

https://github.com/DanielMartensson/MataveID/blob/2e81144d45dd2e77096cdd2846457709038cd429/examples/lbpExample.m#L1-L21

## Result

```matlab
288882440 = 0b10001001101111111111100001000
```
