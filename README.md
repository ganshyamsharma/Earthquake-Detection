# Earthquake-Detection
Detection of earthquake events using various algorithms like PGA, CAV, W-BCAV
## Peak Ground Accelaration (PGA)
It is the maximum value of ground accelaration. <br><p align = "center">PGA = Max{|a(t)|}</p>. The synthesized circuit continuosly monitors the 3 axis accelaration values measured by the ADXL 362 MEMS based sensor. If the measured value exceeds the PGA_THRESHOLD, an alarm signal is generated.
## Cumulative Absolute Velocity (CAV)
It is defined as the time integration of absolute value of accelaration, <br><p align = "center">CAV = $\sum_{0}^{tmax}|a(t)|*dt$</p>. If the integrated value exceeds the set CAV_THRESHOLD value, an alarm signal is generated. This technique is prone to noise, as noise values will keep accumulating and may trigger false alarm.
## Windowed Braceketed Cumultive Absolute Velocity (W-BCAV)
This is a modified method of calculating CAV to avoid the false alarms due to noise.<br> 
<p align = "center">W-BCAV = $\sum_{1}^{winsize}$ $\sum_{t}^{t+dt}|a(t)*dt|$, where max|a(t)| > _Min Acc Level_</p>
Where, _dt_ is the bracketed time generally taken as 1s, and at least one value of the acceleration exceeds a predetermined threshold acceleration level (Min acceleration level). The discrete integration results for 1s bracket intervals are summed for specified window size (win size). The discrete integrals summed within the window size will be continually moving over the time. An alarm will be generated if W-BCAV value exceeds the set W-BCAV THRESHOLD.


