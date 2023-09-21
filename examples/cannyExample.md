# Canny filter
Use this filter if you want to find the edges inside an image

```matlab
[E] = mi.canny(image);
```

## Example

https://github.com/DanielMartensson/MataveID/blob/210c93d528a0ebe7f6f59df54904a77cb529091f/examples/cannyExample.m#L1-L23

## Result
![Canny Result](../pictures/Canny_Result.png)

Notice that Canny is quite slow, but gives very thin edges, which is good. But if you only want to have the edges and you don't care how thick they are.
Then Sobel is the right solution for you because Sobel is much faster than Canny.

```matlab
>> G = mi.sobel(imread('way.jpg'));
>> G(G < 255) = 0; % Every pixel that are not white is going to be black
>> imshow(uint8(G));
```
## Result
![Sobel Result_Way](../pictures/Sobel_Result_Way.png)
