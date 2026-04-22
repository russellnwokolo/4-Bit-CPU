# 4-Bit-CPU
4 Bit CPU Design inspired by Ben Eater's 8 Bit Computer.
This project implements a 4-bit CPU constructed entirely from discrete logic ICs on a breadboard. The CPU is designed to demonstrate core computer architecture concepts such as instruction execution, datapath design, register-based computation, and control via opcodes. The processor uses a 4-bit datapath and is built around TTL/CMOS logic components. The design follows a Harvard architecture, separating instruction memory from the data path. Instructions are 8 bits wide, split into a 4-bit opcode and a 4-bit operand. While minimal in scale, this CPU is designed to implement the essential fetch–decode–execute cycle used in modern processors.

## This Processor consists of 6 Major Subsystems

Instruction Fetch Unit


Instruction Register (IR)


Datapath (Registers + ALU)


System Bus

Output Register

Clock

The system is clocked synchronously with an NE555P Chip (555 Timer), with registers updating on clock edges and combinational logic (such as the ALU) producing results each cycle.

## Instruction Memory and Fetch Unit
The instruction side of the CPU uses a 74HC161 4-bit Program Counter (PC), allowing for up to 16 instruction addresses.
The PC outputs a 4-bit address.
<img width="804" height="734" alt="Screenshot 2026-04-21 212711" src="https://github.com/user-attachments/assets/8381bc01-df4e-4d9e-9c7c-0e2d0ab9b9d5" />


This address feeds directly into an EEPROM, which serves as instruction memory.


The EEPROM outputs an 8-bit instruction word for each PC address.


Because instruction memory is physically separate from the datapath and data bus, this design qualifies as a Harvard architecture.

## Instruction Register (IR)
<img width="506" height="577" alt="Screenshot 2026-04-21 212916" src="https://github.com/user-attachments/assets/d5da924e-dd10-49ad-832e-82cf1495b2e0" />

The 8-bit instruction fetched from EEPROM is latched into the Instruction Register (IR). For this IR, we used two consecutive 74HC173 4-bit registers, allowing for 8 bit latches.
The IR stores the current instruction for the duration of execution.


The instruction is split internally into two fields:


Opcode (4 bits): Tells the Control Unit what operation to perform


Operand (4 bits): Provides immediate data to drive bus or jump the PC


This separation allows the control logic to decode the opcode independently while the operand is routed into the datapath.
Operand Handling and Bus Interface
The operand field of the instruction register is connected to the system bus through a tri-state buffer.
When enabled, the operand can directly drive the 4-bit system bus.


When disabled, the operand is electrically isolated to prevent bus contention.


This design allows immediate values to be injected into the datapath without additional memory access or registers, simplifying the overall control logic.
# Datapath Overview
The datapath is 4 bits wide and consists of:
### A Register – implemented using a 74HC173
<img width="646" height="496" alt="Screenshot 2026-04-21 212059" src="https://github.com/user-attachments/assets/0813f3ff-6300-46ef-85f0-fc0d9de18d91" />



### B Register – implemented using a 74HC173
<img width="665" height="570" alt="Screenshot 2026-04-21 212028" src="https://github.com/user-attachments/assets/c75f0dc2-aa41-4542-951d-5c23057db77b" />


### ALU – implemented using a 74LS181

<img width="694" height="674" alt="Screenshot 2026-04-21 212155" src="https://github.com/user-attachments/assets/1c4b3939-a39b-4a17-9c9a-81f06e82dc79" />

### Output Register – implemented using a separate 74HC173
* Image Uses 74LS48 Chip, but a AT28C256 EEPROM can also be used as the decoder
![Uploading Screenshot 2026-04-21 212711.png…]()
<img width="683" height="445" alt="Screenshot 2026-04-21 212220" src="https://github.com/user-attachments/assets/4878de9f-aebd-461d-8b4c-cef146eada74" />


### Registers
The A and B registers store operands for ALU operations.


Each register can load data from the system bus under control of dedicated enable signals.


Register outputs feed directly into the ALU inputs.


### ALU
The 74LS181 performs arithmetic and logic operations on the contents of the A and B registers.


ALU function selection is controlled by opcode-derived control signals.


The ALU output is routed back onto the system bus or into the output register, depending on the instruction.
Output Register

Implemented using a 74HC173


Loads data from the system bus


Holds output values stable across clock cycles


This register is primarily used for demonstration purposes, allowing instruction results to be easily monitored.
## Design Characteristics and Constraints
Word size: 4 bits


Instruction size: 8 bits (opcode + operand)


Address space: 16 instruction addresses


Architecture: Harvard


Implementation: Breadboarded TTL/CMOS logic


The design prioritizes simplicity and clarity over performance or extensibility. Decisions such as using immediate operands and an accumulator-style datapath were made to reduce hardware complexity and control overhead.

There is also a 4 bit DIP switch used to load immediate values by the users choice for demo testing.

## Fetch-Decode-Execute / Control Unit
The brain of the CPU is a microcoded control unit.
<img width="827" height="586" alt="Screenshot 2026-04-21 213029" src="https://github.com/user-attachments/assets/bbf1607a-e4a2-46ae-82d4-3d1ef1d6e7fb" />

Fetch: The Program Counter (PC) outputs the address to the Instruction Memory (EEPROM), and the resulting 8-bit word is latched into the Instruction Register (IR).

Decode: The 4-bit opcode from the IR drives the address lines of a Control EEPROM. A second binary counter is decoded to be used on the address lines for the control word, useful for instructions that take multiple steps.

Execute: The Control Unit asserts a Control Word which is a series of active-low/high signals that open tri-state buffers and trigger register enable pins. This orchestrates the flow of data across the 4-bit system bus in synchronization with the clock.


### Flags Register & Conditional Logic
To support branching and decision-making, the design includes a Flags Register.

#### Zero Flag (Z): Triggered by a 4-input NOR gate monitoring the ALU bus, asserting when all bits are zero.

#### Carry Flag (C): Captures the carry-out bit from the 74LS181 ALU operations.

Implementation: These flags are latched into a 74HC173 register on the trailing edge of ALU operations.

Conditional Jumps: The "Jump-If-Zero" (JZ) or "Jump-If-Carry" (JC) instructions are implemented using discrete AND gates to gate the Flag Register bits with the Opcode decoder signals. If the condition is met, the Program Counter (PC) load pin is asserted, jumping the execution to the address specified in the instruction operand.
The output register captures results from the datapath for observation or external use.


## Instruction Set Architecture
### Name |     Opcode | Operand  
### LOADA     |  0001 |  xxxx
### LOADB DIP | 0010  |  0000
### ALU SUB  |  0011  |  0000
### Z Jump   |  0100  |  xxxx
### Halt     |   0101 |  0000
### ALU ADD  |  0110  |  0000
### OUT ALU  |  0111  |  0000
### C Jump   |  1000  |  xxxx



## Physical Prototype Limitations 

1. Signal Integrity & Crosstalk
With  hundreds of jumper wires and the implementation being on a breadboard, the circuit will have parasitic capacitance and parasitic inductance. High-speed clock transitions create EMI across adjacent rows, occasionally causing control lines (like Register Enable) to trigger prematurely. This explains unplanned LED behavior during operations. 

2. Voltage Drop & Power Distribution
The cumulative resistance of the breadboard power rails resulted in a non-linear voltage gradient. Despite a stable 5V input, peripheral modules experienced voltage sag, dropping logic levels below the Vi_H (Input High) threshold for certain CMOS chips, leading to undefined logic states.

3. Conclusion of Project
This project was a multi-month deep dive into low-level hardware abstraction. Having successfully implemented the datapath, ALU, and fetch-cycle logic, the project was overall a great learning experience. The challenges faced in the bring-up phase provided me with practical experience in hardware debugging and the necessity of PCB ground planes for complex synchronous logic.
