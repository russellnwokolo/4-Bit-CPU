## Physical Prototype Limitations 

1. Signal Integrity & Crosstalk
With  hundreds of jumper wires and the implementation being on a breadboard, the circuit will have parasitic capacitance and parasitic inductance. High-speed clock transitions create EMI across adjacent rows, occasionally causing control lines (like Register Enable) to trigger prematurely. This explains unplanned LED behavior during operations. 

2. Voltage Drop & Power Distribution
The cumulative resistance of the breadboard power rails resulted in a non-linear voltage gradient. Despite a stable 5V input, peripheral modules experienced voltage sag, dropping logic levels below the Vi_H (Input High) threshold for certain CMOS chips, leading to undefined logic states.

3. Conclusion of Project
This project was a multi-month deep dive into low-level hardware abstraction. Having successfully implemented the datapath, ALU, and fetch-cycle logic, the project was overall a great learning experience. The challenges faced in the bring-up phase provided me with practical experience in hardware debugging and the necessity of PCB ground planes for complex synchronous logic.


#### This Demo Vid shows the physical breadboard implementation of the CPU

## Unlisted Video: https://youtu.be/TgJ3NvlFTbY
