Description:

Advanced Microcontroller Bus Architecture (AMBA) is a System-on-Chip (SoC) bus protocol defining a set of interconnect specifications that standardize on-chip communication. 

Advanced High-Performance Bus (AHB) is a high-performance bus designed to connect faster components that need higher bandwidth on a shared bus, such as memory, processor, DSP, etc.
Advanced Peripheral Bus (APB) is a simple, low-power, and low-speed bus protocol used to connect peripheral devices in an SoC.
 
AHB to APB Bridge acts as an interface that connects the AHB and APB buses and allows slower peripherals connected to the APB to communicate with faster peripherals connected to the AHB.

HDL: Verilog

EDA Tool: Xilinx Vivado

Results:

• Synthesizable design of AHB2APB Bridge.
• Designed AHB Master and APB Slave interfaces to initiate transactions over the bridge.
• Verilog Testbench to verify the working.
• Single Read and Single Write transfers verified.
