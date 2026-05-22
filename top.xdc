
## ------------------------------------------------------------
## Clock - 100 MHz on-board oscillator
## ------------------------------------------------------------
set_property PACKAGE_PIN W5      [get_ports clk]
set_property IOSTANDARD  LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


## ------------------------------------------------------------
## Reset - Center button (BTNC)
## ------------------------------------------------------------
set_property PACKAGE_PIN U18     [get_ports rst]
set_property IOSTANDARD  LVCMOS33 [get_ports rst]


## ------------------------------------------------------------
## DIP switches - SW0..SW3  (dip[0]..dip[3])
## (right-most four switches on the board)
## ------------------------------------------------------------
set_property PACKAGE_PIN V17     [get_ports {dip[0]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {dip[0]}]

set_property PACKAGE_PIN V16     [get_ports {dip[1]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {dip[1]}]

set_property PACKAGE_PIN W16     [get_ports {dip[2]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {dip[2]}]

set_property PACKAGE_PIN W17     [get_ports {dip[3]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {dip[3]}]


## ------------------------------------------------------------
## 7-Segment Display - seg[6:0]
## seg[0]=CA  seg[1]=CB  seg[2]=CC  seg[3]=CD
## seg[4]=CE  seg[5]=CF  seg[6]=CG
## (active-low cathodes)
## ------------------------------------------------------------
set_property PACKAGE_PIN W7      [get_ports {seg[0]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[0]}]

set_property PACKAGE_PIN W6      [get_ports {seg[1]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[1]}]

set_property PACKAGE_PIN U8      [get_ports {seg[2]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[2]}]

set_property PACKAGE_PIN V8      [get_ports {seg[3]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[3]}]

set_property PACKAGE_PIN U5      [get_ports {seg[4]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[4]}]

set_property PACKAGE_PIN V5      [get_ports {seg[5]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[5]}]

set_property PACKAGE_PIN U7      [get_ports {seg[6]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[6]}]


## ------------------------------------------------------------
## 7-Segment Digit Anodes - an[3:0]  (active-low)
## an[0] = rightmost digit, an[3] = leftmost digit
## ------------------------------------------------------------
set_property PACKAGE_PIN U2      [get_ports {an[0]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {an[0]}]

set_property PACKAGE_PIN U4      [get_ports {an[1]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {an[1]}]

set_property PACKAGE_PIN V4      [get_ports {an[2]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {an[2]}]

set_property PACKAGE_PIN W4      [get_ports {an[3]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {an[3]}]


## ------------------------------------------------------------
## Carry-out - LED0  (LD0, rightmost LED)
## ------------------------------------------------------------
set_property PACKAGE_PIN W18     [get_ports c_out]
set_property IOSTANDARD  LVCMOS33 [get_ports c_out]


## ------------------------------------------------------------
## Configuration / Bitstream options
## ------------------------------------------------------------
set_property CONFIG_VOLTAGE    3.3 [current_design]
set_property CFGBVS            VCCO [current_design]
