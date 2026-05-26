# 4-Bit-CPU
Inspired by Ben Eater’s 8-bit computer architecture, this project features two distinct implementations of a 4-bit CPU: a physical prototype constructed with discrete logic and a digital twin designed in Verilog.

These implementations demonstrate the transition from real life hardware-level constraints to higher level digital design. The architecture follows a Harvard Architecture Design, physically separating instruction memory from the datapath to streamline the fetch–decode–execute cycle.

### Design Implementations
Physical Prototype: A breadboard-based construction using discrete TTL/CMOS logic ICs. This version emphasizes real-world electrical considerations, signal integrity, and manual hardware debugging using testing equipment.

RTL Design (Verilog): A synthesizable hardware description model. This version provides a digital environment for timing analysis via waveforms and gate-level logic synthesis.

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

This address feeds directly into an EEPROM, which serves as instruction memory.


The EEPROM outputs an 8-bit instruction word for each PC address.


Because instruction memory is physically separate from the datapath and data bus, this design qualifies as a Harvard architecture.

## Instruction Register (IR)


The 8-bit instruction fetched from EEPROM is latched into the Instruction Register (IR). For this IR, we used two consecutive 74HC173 4-bit registers, allowing for 8 bit latches.
The IR stores the current instruction for the duration of execution.


The instruction is split internally into two fields:


Opcode (4 bits): Tells the Control Unit what operation to perform


Operand (4 bits): Provides immediate data to drive bus or jump the PC


This separation allows the control logic to decode the opcode independently while the operand is routed into the datapath.
Operand Handling and Bus Interface
The operand field of the instruction register is connected to the system bus through a tri-state buffer.


When disabled, the operand is electrically isolated to prevent bus contention.


This design allows immediate values to be injected into the datapath without additional memory access or registers, simplifying the overall control logic.
# Datapath Overview
The datapath is 4 bits wide and consists of:
### General Registers – implemented using a 74HC173 Chips

The A and B registers store operands for ALU operations.


Each register can load data from the system bus under control of dedicated enable signals.


Register outputs feed directly into the ALU inputs.

Discrete Implementation

### ALU – implemented using a 74LS181

The 74LS181 performs arithmetic and logic operations on the contents of the A and B registers.


ALU function selection is controlled by opcode-derived control signals.


The ALU output is routed back onto the system bus or into the output register, depending on the instruction.



### Output Register – implemented using a separate 74HC173

Implemented using a 74HC173


Loads data from the system bus


Holds output values stable across clock cycles

* Image Uses 74LS48 Chip, but a AT28C256 EEPROM can also be used as the decoder

This register is primarily used for demonstration purposes, allowing instruction results to be easily monitored.
## Design Characteristics and Constraints
Word size: 4 bits


Instruction size: 8 bits (opcode + operand)


Address space: 16 instruction addresses


Architecture: Harvard


### Implementation: Breadboarded TTL/CMOS logic


The design prioritizes simplicity and clarity over performance. Decisions such as using immediate operands and an accumulator-style datapath were made to reduce hardware complexity and control overhead.

There is also a 4 bit DIP switch used to load immediate values by the users choice for demo testing.

## Fetch-Decode-Execute / Control Unit

The brain of the CPU is a microcoded control unit.

Fetch: The Program Counter (PC) outputs the address to the Instruction Memory (EEPROM), and the resulting 8-bit word is latched into the Instruction Register (IR).

Decode: The 4-bit opcode from the IR drives the address lines of a Control EEPROM. A second binary counter is decoded to be used on the address lines for the control word.

Execute: The Control Unit asserts a Control Word that orchestrates the flow of data across the 4-bit system bus in synchronization with the clock.


### Flags Register & Conditional Logic
To support branching and decision-making, the design includes a Flags Register.

#### Zero Flag (Z): Triggered by a 4-input NOR gate monitoring the ALU bus, asserting when all bits are zero.

#### Carry Flag (C): Captures the carry-out bit from the 74LS181 ALU operations.

Implementation: These flags are latched into a 74HC173 register on the trailing edge of ALU operations.

Conditional Jumps: The "Jump-If-Zero" (JZ) or "Jump-If-Carry" (JC) instructions are implemented using discrete AND gates to gate the Flag Register bits with the Opcode decoder signals. If the condition is met, the Program Counter (PC) load pin is asserted, jumping the execution to the address specified in the instruction operand.


## Instruction Set Architecture
### Name      | Opcode| Operand  
### LOADA DIP |  0001 |  0000
### LOADB IMM |  0010 |  xxxx
### OUT ALU   |  0011 |  0000
### ALU SUB   |  0100 |  0000
### NOT C JUMP|  0101 |  xxxx
### NOT Z JUMP|  0110 |  xxxx
### HALT      |  0111 |  0000



