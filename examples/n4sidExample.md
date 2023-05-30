# N4SID - Numerical algorithm for Subspace State Space System IDentification.
N4SID is an algoritm that identify a linear state space model. Use this if you got regular data from a dynamical system. This algorithm can handle both SISO and MISO. N4SID algorithm was invented 1994. If you need a nonlinear state space model, check out the SINDy algorithm. Try N4SID or MOESP. They give the same result, but sometimes N4SID can be better than MOESP. It all depends on the data.

```matlab
[sysd, K] = mi.n4sid(u, y, k, sampleTime, ktune, delay, systemorder); % k = Integer tuning parameter such as 10, 20, 25, 32, 47 etc. ktune = kalman filter tuning such as 0.1, 0.01 etc
```
## Example N4SID

Here I programmed a Beijer PLC that controls the multivariable cylinder system. It's a nonlinear system, but N4SID can handle it because it's not so nonlinear as a hydraulic motor. Cylinder 0 and Cylinder 1 affecting each other when the propotional control valves opens.

![PLC system](../pictures/PLC%20system.jpg)

![OKID System](../pictures/OKID_System.jpg)

https://github.com/DanielMartensson/MataveID/blob/4c18a134f9590a6a952d9c5b4710332d6482434d/examples/n4sidExample.m#L1-L45

![OKID Result](../pictures/OKID_Result.png)