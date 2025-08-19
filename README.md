# Earthquake-Detection
Detection of earthquake events using various algorithms like PGA, CAV, W-BCAV
## Peak Ground Accelaration (PGA)
It is the maximum value of ground accelaration. <p align = "center">PGA = Max{|a(t)|}</p>The synthesized circuit continuosly monitors the 3 axis accelaration values measured by the ADXL 362 MEMS based sensor. If the measured value exceeds the PGA_THRESHOLD, an alarm signal is generated.
## Cumulative Absolute Velocity (CAV)
It is defined as the time integration of absolute value of accelaration. <p align = "center">CAV = $\sum_{0}^{tmax}|a(t)|*dt$</p>If the integrated value exceeds the set CAV_THRESHOLD value, an alarm signal is generated. This technique is prone to noise, as noise values will keep accumulating and may trigger false alarm.
## Windowed Braceketed Cumultive Absolute Velocity (W-BCAV)
This is a modified method of calculating CAV to avoid the false alarms due to noise. <p align = "center">W-BCAV = $\sum_{1}^{winsize}$ $\sum_{t}^{t+dt}|a(t)*dt|$, where max|a(t)| > Min Acc Level</p>Where, *dt* is the bracketed time generally taken as 1s, and at least one value of the acceleration exceeds a predetermined threshold acceleration level (Min acceleration level). The discrete integration results for 1s bracket intervals are summed for specified window size (win size). The discrete integrals summed within the window size will be continually moving over the time. An alarm will be generated if W-BCAV value exceeds the set W-BCAV THRESHOLD.
# Source Files Description
- adxl362_config: Top level module, all other modules are instantiated in this module. It configures the  ADXL 362 sensor by writing to its internal registers and acquire the raw 16 bit (2's complement) 3-axis accelaration values over SPI. More details on the sensor can be found at [Analog Devices](https://www.analog.com/media/en/technical-documentation/data-sheets/adxl362.pdf).
- scaler: Takes the raw 16 bit accelaration values and process them as follows.
    - Offset correction is done on the raw values, as Z-axis data shows 1g value due to gravity.
    - Absolute of the accelaration values are taken, as algorithms require only positive acc. values.
    - The values are then multiplied with 0.001 to convert them into respective accelaration (in g) values. As 1LSB = 0.001g for a sensor range of +-2g.
- pga: This module takes the scaled 3-axis acc. data and implements the PGA algorithm to generate PGA alarm.
- cav: Takes the scaled 3-axis acc. data and implements the CAV algorithm to generate PGA alarm. The RECORD_TIME (tmax) and CAV_THRESHOLD can be adjusted in this module.
- wbcav: Implements the W-BCAV algorithm. Window size, Min. Acc. Value for a valid window (WINDOW_THRESHOLD) of 1s and WBCAV_THRESHOLD can be adusted in this module.


