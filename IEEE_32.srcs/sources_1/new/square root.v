`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.09.2025 21:03:51
// Design Name: 
// Module Name: square_root
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


module square_root (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,        // start pulse
    input  wire [31:0] A,            // operand
    input  wire [31:0] x0,           // initial guess
    output reg  [31:0] Res,          // final sqrt result
    output reg         done          // 1-cycle pulse when result valid
);

    // Constant 0.5 in IEEE-754
    localparam [31:0] HALF = 32'h3F000000;

    // FSM states
    localparam IDLE  = 3'd0,
               DIV1  = 3'd1,
               ITER1 = 3'd2,
               DIV2  = 3'd3,
               ITER2 = 3'd4,
               DIV3  = 3'd5,
               ITER3 = 3'd6,
               DONE  = 3'd7;

    reg [2:0] state, next_state;

    // Registers for iteration variables
    reg [31:0] xn;        // current guess
    reg [31:0] div_out;   // division result
    reg [31:0] sum_temp;  // add/sub result
    reg [31:0] mult_temp; // mult result

    // Wires for connected blocks
    wire [31:0] div_res, add_res, mul_res;

    // Instantiate reusable arithmetic blocks
    division u_div (.clk(clk), .A(A), .B(xn), .Result(div_res));
    ADD_SUB  u_add (.A(xn), .B(div_out), .OP(1'b0), .out(add_res));
    mult754  u_mul (.clk(clk), .A(sum_temp), .B(HALF), .RES(mul_res));

    // Simple latency counters for division (simulate realistic delay)
    // In real design, you'd count the division latency or use handshake
    reg [5:0] div_cnt;
    localparam DIV_LAT = 9;  // ~9 cycles per division

    // FSM: Sequential
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:  if (start) next_state = DIV1;
            DIV1:  if (div_cnt == DIV_LAT) next_state = ITER1;
            ITER1: next_state = DIV2;
            DIV2:  if (div_cnt == DIV_LAT) next_state = ITER2;
            ITER2: next_state = DIV3;
            DIV3:  if (div_cnt == DIV_LAT) next_state = ITER3;
            ITER3: next_state = DONE;
            DONE:  next_state = IDLE;
        endcase
    end

    // FSM: Outputs and operations
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            xn        <= 32'b0;
            div_out   <= 32'b0;
            sum_temp  <= 32'b0;
            mult_temp <= 32'b0;
            Res       <= 32'b0;
            done      <= 1'b0;
            div_cnt   <= 0;
        end else begin
            done <= 1'b0; // default
            case (state)
                IDLE: begin
                    xn      <= x0;
                    div_cnt <= 0;
                end

                DIV1, DIV2, DIV3: begin
                    div_cnt <= div_cnt + 1;
                    if (div_cnt == DIV_LAT)
                        div_out <= div_res; // capture division output
                end

                ITER1, ITER2, ITER3: begin
                    sum_temp  <= add_res;
                    mult_temp <= mul_res;
                    xn        <= mult_temp; // update guess
                end

                DONE: begin
                    Res  <= xn;
                    done <= 1'b1;
                end
            endcase
        end
    end

endmodule

