`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2025 22:49:31
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fpu_top (
    input clk,
    input reset,
    input [31:0] opA,
    input [31:0] opB,
    input [2:0]  opcode,
    input        valid_in,
    output       ready,
    output reg [31:0] result,
    output reg        valid_out
);


localparam ADD  = 3'b000;
localparam SUB  = 3'b001;
localparam MUL  = 3'b010;
localparam DIV  = 3'b011;
localparam SQRT = 3'b100;


wire is_addsub = (opcode == ADD) || (opcode == SUB);
wire is_mul    = (opcode == MUL);
wire is_div    = (opcode == DIV);
wire is_sqrt   = (opcode == SQRT);


reg [1:0] op_type;
always @(*) begin
    if (is_addsub)
        op_type = 2'd0;
    else if (is_mul)
        op_type = 2'd1;
    else if (is_div)
        op_type = 2'd2;
    else if (is_sqrt)
        op_type = 2'd3;
    else
        op_type = 2'd0;
end


reg slot_busy[0:3][0:3];  
reg [1:0] next_slot;
reg [1:0] slot_sel;

wire slot_available = 
    ~slot_busy[0][op_type] |
    ~slot_busy[1][op_type] |
    ~slot_busy[2][op_type] |
    ~slot_busy[3][op_type];



reg [32:0] rob_data [0:15];
reg [15:0] rob_valid;
reg [15:0] rob_done;
reg [3:0] rob_head;
reg [3:0] rob_tail;

wire rob_full = (rob_head == rob_tail) && rob_valid[rob_head];
assign ready = slot_available && !rob_full;


wire [31:0] addsub_res [0:3];
wire [31:0] mul_res    [0:3];
wire [31:0] div_res    [0:3];
wire [31:0] sqrt_res   [0:3];

wire [3:0] addsub_done, mul_done, div_done, sqrt_done;


genvar i;
generate
    for (i = 0; i < 4; i = i + 1) begin : gen_units
        ADD_SUB addsub (
            .A(opA), .B(opB),
            .OP(opcode[0]),
            //.in_valid(valid_in && ready && (next_slot == i) && is_addsub),
            .out(addsub_res[i])
            //.done(addsub_done[i])
        );

        mult754 mul (
            .clk(clk),
            .A(opA), .B(opB),
            //.in_valid(valid_in && ready && (next_slot == i) && is_mul),
            .RES(mul_res[i])
            //.done(mul_done[i])
        );

        div_top div (
            .clk(clk),
            .A(opA), .B(opB),
            //.in_valid(valid_in && ready && (next_slot == i) && is_div),
            .Res(div_res[i])
            //.done(div_done[i])
        );

        sqrt_top sqrt (
            .clk(clk), .reset(reset),
            .A(opA),
            //.in_valid(valid_in && ready && (next_slot == i) && is_sqrt),
            .Result(sqrt_res[i])
            //.done(sqrt_done[i])
        );
    end
endgenerate


integer j, k;
integer tag;


always @(*) begin
    if (!slot_busy[0][op_type])
        next_slot = 2'd0;
    else if (!slot_busy[1][op_type])
        next_slot = 2'd1;
    else if (!slot_busy[2][op_type])
        next_slot = 2'd2;
    else
        next_slot = 2'd3;
end


always @(posedge clk or posedge reset) begin
    if (reset) begin
        rob_head <= 0;
        rob_tail <= 0;
        rob_valid <= 16'd0;
        rob_done  <= 16'd0;
        result <= 32'd0;
        valid_out <= 1'b0;
        slot_sel <= 2'd0;
        for (j = 0; j < 4; j = j + 1)
            for (k = 0; k < 4; k = k + 1)
                slot_busy[j][k] <= 1'b0;
    end else begin
        valid_out <= 1'b0;

      
        if (valid_in && ready) begin
            slot_sel <= next_slot;
            slot_busy[next_slot][op_type] <= 1'b1;
            rob_data[rob_tail] <= {opcode, next_slot, op_type}; // tag
            rob_valid[rob_tail] <= 1'b1;
            rob_done[rob_tail] <= 1'b0;
            rob_tail <= rob_tail + 1;
        end

        
        for (j = 0; j < 4; j = j + 1) begin
            if (addsub_done[j]) begin
                for (tag = 0; tag < 16; tag = tag + 1) begin
                    if (rob_valid[tag] && rob_data[tag][5:4] == 2'd0 && rob_data[tag][3:2] == j && !rob_done[tag]) begin
                        rob_data[tag] <= addsub_res[j];
                        rob_done[tag] <= 1'b1;
                        slot_busy[j][0] <= 1'b0;
                    end
                end
            end
            if (mul_done[j]) begin
                for (tag = 0; tag < 16; tag = tag + 1) begin
                    if (rob_valid[tag] && rob_data[tag][5:4] == 2'd1 && rob_data[tag][3:2] == j && !rob_done[tag]) begin
                        rob_data[tag] <= mul_res[j];
                        rob_done[tag] <= 1'b1;
                        slot_busy[j][1] <= 1'b0;
                    end
                end
            end
            if (div_done[j]) begin
                for (tag = 0; tag < 16; tag = tag + 1) begin
                    if (rob_valid[tag] && rob_data[tag][5:4] == 2'd2 && rob_data[tag][3:2] == j && !rob_done[tag]) begin
                        rob_data[tag] <= div_res[j];
                        rob_done[tag] <= 1'b1;
                        slot_busy[j][2] <= 1'b0;
                    end
                end
            end
            if (sqrt_done[j]) begin
                for (tag = 0; tag < 16; tag = tag + 1) begin
                    if (rob_valid[tag] && rob_data[tag][5:4] == 2'd3 && rob_data[tag][3:2] == j && !rob_done[tag]) begin
                        rob_data[tag] <= sqrt_res[j];
                        rob_done[tag] <= 1'b1;
                        slot_busy[j][3] <= 1'b0;
                    end
                end
            end
        end

        
        if (rob_valid[rob_head] && rob_done[rob_head]) begin
            result <= rob_data[rob_head];
            valid_out <= 1'b1;
            rob_valid[rob_head] <= 1'b0;
            rob_head <= rob_head + 1;
        end
    end
end

endmodule
