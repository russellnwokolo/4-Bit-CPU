`include "4_bit_cpu.v"

`timescale 1ns/1ps

module tb_top;
    reg clk, rst;
    reg [3:0] dip;
    wire [3:0] display;
    wire c_out;
    wire [6:0] seg;   // adjust width to match your top module
    wire [3:0] an; 
    top uut (
        .clk     (clk),
        .rst     (rst),
        .sw (dip),
        .seg (seg),
        .an  (an),
        .c_out   (c_out),
        .dip     (dip)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
        rst = 1;
        dip = 4'd10;
        #20;
        rst=0;

        #900;
        $finish;
    end


endmodule
