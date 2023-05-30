# RLS - Recursive Least Squares
RLS is an algorithm that creates a SISO model from data. Here you can select if you want to estimate an ARX, OE model or an ARMAX model, depending on the number of zeros in the polynomal "nze". Select number of error-zeros-polynomal "nze" to 1, and you will get a ARX model or select "nze" equal to model poles "np", you will get an ARMAX model that also includes a kalman gain matrix K. I recommending that. This algorithm can handle data with noise. This algorithm was invented 1821 by Carl Friedrich Gauss, but it was until 1950 when it got its attention in adaptive control.

Use this algorithm if you have data from a open/close loop system and you want to apply that algorithm into embedded system that have low RAM and low flash memory. RLS is very suitable for system that have a lack of memory.

There is a equivalent C-code for RLS algorithm here. Works on ALL embedded systems.
https://github.com/DanielMartensson/CControl

```matlab
[sysd, K] = mi.rls(u, y, np, nz, nze, sampleTime, delay, forgetting);
```

Notice that there are sevral functions that simplify the use of `rls.m`

```matlab
[sysd, K] = mi.oe(u, y, np, nz, sampleTime, delay, forgetting);
[sysd, K] = mi.arx(u, y, np, nz, sampleTime, ktune, delay, forgetting);
[sysd, K] = mi.armax(u, y, np, nz, nze, sampleTime, ktune, delay, forgetting);
```

## Example RLS

This is a hanging load of a hydraulic system. This system is a linear system due to the hydraulic cylinder that lift the load. Here I create two linear first order models. One for up lifting up and one for lowering down the weight. I'm also but a small orifice between the outlet and inlet of the hydraulic cylinder. That's create a more smooth behavior. Notice that this RLS algorithm also computes a Kalman gain matrix.

![RLS System](../pictures/RLS_System.jpg)

https://github.com/DanielMartensson/MataveID/blob/2014b74a0863729b43e0ee02ecdcd4fcbc06b26b/examples/rlsExample.m#L1-L60

Here we can se that the first model follows the measured position perfect. The "down-curve" should be measured a little bit longer to get a perfect linear model.

![RLS Result](../pictures/RLS_Result.png)