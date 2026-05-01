
module program_counter(dc, p, load, cep, cet, rst, clk);

    input[3:0] dc;
    output reg[3:0] p;
    input load;
    input cep;
    input cet;
    input rst;
    input clk;

    localparam ON = 1;
    localparam OFF = 0;

    reg[3:0] current_state = 1;
    reg[3:0] next_state;


    always@(*)begin
        next_state = current_state;
        if(cep && cet && ~load)begin
            next_state = current_state + 1;
        end else if(load)begin
            next_state = dc;
        end
    end

    always@(posedge clk or posedge rst)begin
        if (rst)begin
        current_state <= 0;
        p <= 0;
        end else begin
        current_state <= next_state;
        p <= next_state;
        end
    end
endmodule

module instruction_EEPROM(addr, qe, OE);
    input[3:0] addr;
    output reg[7:0] qe;
    input OE;

    localparam LOADA_DIP = 8'b11100000;
    localparam LOADB_3 = 8'b00010010;
    localparam ALU_SUB = 8'b00100000;
    localparam NOT_Z_JUMP_2 = 8'b00110010;
    localparam HALT = 8'b01010000;
    localparam OUT_ALU = 8'b01110000;
    localparam NOT_CARRY_2 = 8'b10000010;


    always@(*)begin
            case(addr)
                4'b0001: begin
                    qe = LOADA_DIP;
                end
                4'b0010: begin
                    qe = LOADB_3;
                end
                4'b0011: begin
                    qe = OUT_ALU;
                end
                4'b0100: begin
                    qe = ALU_SUB;
                end
                4'b0101:begin
                    qe = NOT_CARRY_2;
                end
                4'b0110:begin
                    qe = NOT_Z_JUMP_2;
                end
                4'b0111:begin
                    qe = HALT;
                end
                default:begin
                    qe = 8'b00000000;
                end
                    endcase
                end 
endmodule

module instruction_register(di, opcode, operand_out, operand_direct, en_ir, clk, rst);
    input clk;
    input en_ir;
    input rst;
    input[7:0] di;
    output reg[3:0] opcode;
    output wire [3:0] operand_out;
    reg[3:0] operand;
    output wire [3:0] operand_direct;

    assign operand_direct = operand;
    assign operand_out    = operand;  // always drives, mux in top selects it

    always@(posedge clk) begin
        if(rst) begin
            operand <= 0;
            opcode  <= 0;
        end else if(en_ir) begin
            operand <= di[3:0];
            opcode  <= di[7:4];
        end
    end
endmodule

module reg_a(da, qa, en_a, clk, rst);

    input[3:0] da;
    input clk;
    input en_a;
    input rst;
    output reg[3:0] qa;

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            qa <= 0;
        end
        else if(en_a)begin
            qa <= da;
        end
    end
endmodule

module reg_b(db, qb, en_b, clk, rst);

    input[3:0] db;
    input clk;
    input en_b;
    input rst;
    output reg[3:0] qb;

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            qb <= 0;
        end
        else if(en_b)begin
            qb <= db;
        end
    end
endmodule

module reg_out(do, out, en_out, clk, rst);

    input[3:0] do;
    input clk;
    input rst;
    input en_out;
    output reg[3:0] out;

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            out <= 0;
        end
        else if(en_out)begin
            out <= do;
        end
    end
endmodule       

module imm_dip(dip, imm_val);
    input wire[3:0] dip;
    output wire[3:0] imm_val;
    assign imm_val = dip;
endmodule


module alu(a, b, s, c_out, always_out);
    input[3:0] a;
    input[3:0] b;
    input[3:0] s;
    output wire c_out;
    output wire [3:0] always_out;
    reg [4:0] temp;

    always @(*) begin
        case(s)
            4'b1100: temp = a + b;
            4'b0110: temp = a - b;
            4'b1000: temp = {1'b0, a & b};
            4'b0001: temp = {1'b0, a | b};
            default: temp = 5'b0;
        endcase
    end

    assign always_out = temp[3:0];
    assign c_out      = temp[4];
endmodule

module control_unit(opcode_in, control_word, clk, rst, alu_f, carry_signal);
    input wire[3:0] opcode_in;
    output reg[14:0] control_word;
    input wire clk;
    input wire[3:0] alu_f;
    input wire carry_signal;
    input wire rst;
    //seperate control_word

    reg[2:0] counter = 0;
    reg[1:0] flags_reg = 2'b00;
    wire[6:0] control_word_eeprom;
    reg[5:0] decoded_counter; // to decode the counter
    reg halted = 0;
    //decode the counter
    // Control word bit indices
    localparam EN_A         = 0;
    localparam EN_B         = 1;
    localparam ALU_OUT      = 2;
    localparam OUT_EN       = 3;
    localparam PC_LOAD      = 4;
    localparam PC_INC       = 5;
    localparam EN_IR        = 6;
    localparam OPERAND_OUT  = 7;
    localparam IMM_OUT      = 8;
    localparam PC_OUT       = 9; //redundant
    localparam PC_LOAD_COND = 10;
    localparam S1           = 11;
    localparam S2           = 12;
    localparam S3           = 13;
    localparam S4           = 14;

    // Flags bit indices
    localparam CARRY_BIT = 0;
    localparam ZERO_BIT = 1;

    always@(*)begin
        //decodes the counter
        case (counter)
        3'd0: decoded_counter = 6'b000001;
        3'd1: decoded_counter = 6'b000010;
        3'd2: decoded_counter = 6'b000100;
        3'd3: decoded_counter = 6'b001000;
        3'd4: decoded_counter = 6'b010000;
        3'd5: decoded_counter = 6'b100000;
        default: decoded_counter = 6'b000000;
    endcase
    end

    assign control_word_eeprom = {opcode_in, counter};
    //make the binary counter

    always@(negedge clk or posedge rst)begin
        if(rst)begin //reset counter at 6 because we only need that
            counter <= 0; // resets counter
            flags_reg <= 0;
            halted <= 0;
        end else if(halted)begin
            //frozen
        end else if(counter == 2)begin
            counter <= 0;
            flags_reg[CARRY_BIT] <= carry_signal;
            flags_reg[ZERO_BIT]  <= (alu_f == 0); // but see note below
            if(opcode_in == 4'b0101)begin
                counter <= 0;
            end
        end else begin
            counter <= counter + 1; //adds to the counter
        end
        end
    always@(*)begin
        // fetch steps
        if(decoded_counter == 6'b000001 )begin
            control_word = 0;
            control_word[EN_IR] = 1;
        end
        else if(decoded_counter == 6'b000010)begin
            control_word = 0; //resets control word
            control_word[PC_INC] = 1;
        end else begin
        case(control_word_eeprom)

        //loadA_dip
        7'b1110010: begin control_word = 0;
        control_word[EN_A] = 1;
        control_word[IMM_OUT] = 1;
        end
      
        //loadB_3
        7'b0001010: begin
            control_word = 0;
            control_word[EN_B]        = 1;
            control_word[OPERAND_OUT] = 1;
        end
        //ALU_SUB
        7'b0010010: begin
            control_word = 0;
            control_word[EN_A]    = 1;
            control_word[ALU_OUT] = 1;
            control_word[S2]      = 1;  // S = 0110 = subtract
            control_word[S3]      = 1;
        end
        //NOT_Z_JUMP_2
        7'b0011010: begin
            control_word = 0;
            if (~flags_reg[ZERO_BIT]) begin
                control_word[PC_LOAD]     = 1;
                control_word[OPERAND_OUT] = 1;
            end else begin
                control_word[PC_INC] = 1;
            end
        end

        //HALT
        7'b0101010: begin control_word = 0; 
        halted = 1; end
        //OUT_ALU
        7'b0111010: begin
            control_word = 0;
            control_word[OUT_EN]  = 1;
            control_word[ALU_OUT] = 1;
            control_word[S2]      = 1;  // keep ALU in subtract mode so result is valid
            control_word[S3]      = 1;
        end
        //NOT_CARRY_2
        7'b1000010: begin
            control_word = 0;
            if (~flags_reg[CARRY_BIT]) begin
                control_word[PC_LOAD]     = 1;
                control_word[OPERAND_OUT] = 1;
            end else begin
                control_word[PC_INC] = 1;
            end
        end
        default: control_word = 0;
        endcase
        end
    end

endmodule

    
module top(
    input clk, rst,
    output [3:0] display,
    output c_out,
    input wire [3:0] dip
);
    wire en_a, en_b, alu_out, out_en, load_pc, pc_inc;
    wire en_ir, operand_out_en, imm_out, pc_out, pc_load_cond;
    wire [3:0] s;
    wire [3:0] opcode;
    wire [3:0] p;
    wire [7:0] qe;
    wire [3:0] bus;
    wire [3:0] qa, qb;
    wire [3:0] operand;
    wire [3:0] alu_out_for_f;
    wire [3:0] ir_to_bus;
    wire [3:0] imm_to_bus;
    wire [14:0] control_word;

    assign en_a           = control_word[0];
    assign en_b           = control_word[1];
    assign alu_out        = control_word[2];
    assign out_en         = control_word[3];
    assign load_pc        = control_word[4];
    assign pc_inc         = control_word[5];
    assign en_ir          = control_word[6];
    assign operand_out_en = control_word[7];
    assign imm_out        = control_word[8];
    assign pc_out         = control_word[9];
    assign pc_load_cond   = control_word[10];
    assign s              = control_word[14:11];

    // Explicit bus mux - only one source drives at a time
    assign bus = alu_out        ? alu_out_for_f :
                 imm_out        ? imm_to_bus    :
                 operand_out_en ? ir_to_bus      :
                 4'b0;

    control_unit u_cu (
        .opcode_in    (opcode),
        .control_word (control_word),
        .clk          (clk),
        .rst          (rst),
        .alu_f        (alu_out_for_f),
        .carry_signal (c_out)
    );

    reg_a u_reg_a (
        .da   (bus),
        .qa   (qa),
        .clk  (clk),
        .rst  (rst),
        .en_a (en_a)
    );

    reg_b u_reg_b (
        .db   (bus),
        .qb   (qb),
        .clk  (clk),
        .rst  (rst),
        .en_b (en_b)
    );

    alu u_alu (
        .a          (qa),
        .b          (qb),
        .always_out (alu_out_for_f),
        .s          (s),
        .c_out      (c_out)
    );

    reg_out u_reg_out (
        .do      (bus),
        .out     (display),
        .clk     (clk),
        .rst     (rst),
        .en_out  (out_en)
    );

    instruction_register u_ir (
        .operand_out    (ir_to_bus),
        .operand_direct (operand),
        .opcode         (opcode),
        .en_ir          (en_ir),
        .clk            (clk),
        .rst            (rst),
        .di             (qe)
    );

    instruction_EEPROM u_eeprom (
        .addr (p),
        .qe   (qe),
        .OE   (pc_out)
    );

    imm_dip u_imm_dip (
        .dip     (dip),
        .imm_val (imm_to_bus)
    );

    program_counter u_pc (
        .rst  (rst),
        .clk  (clk),
        .dc   (operand),
        .load (load_pc),
        .cep  (pc_inc),
        .cet  (pc_inc),
        .p    (p)
    );
endmodule





    



