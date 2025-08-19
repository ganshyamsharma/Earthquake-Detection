# Earthquake-Detection
Detection of earthquake events using various algorithms like PGA, CAV, W-BCAV
## Peak Ground Accelaration (PGA)
It is the maximum value of ground accelaration, *PGA = Max{|a(t)|}*. The synthesized circuit continuosly monitors the 3 axis accelaration values measured by the ADXL 362 MEMS based sensor. If the measured value exceeds the PGA_THRESHOLD, an alarm signal is generated.
## Cumulative Absolute Velocity (CAV)
It is defined as the time integration of absolute value of accelaration, CAV = $\sum_{0}^{tmax} |a(t)|*dt$. 

