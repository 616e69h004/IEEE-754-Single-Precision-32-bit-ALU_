`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.11.2025 21:28:55
// Design Name: 
// Module Name: sqrt_exception
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


module sqrt_exception(
    input  wire       sign_A,
    input  wire [6:0] flag_A,
    output reg        valid,
    output reg [15:0] exception
);

    // Flag definitions
    localparam Qnan       = 7'b0000001;
    localparam Snan       = 7'b0000010;
    localparam Inf        = 7'b0000100;
    localparam Zero       = 7'b0001000;
    localparam SubNormal  = 7'b0010000;
    localparam Normal     = 7'b0100000;

    // Predefined results
    wire [15:0] Qnan_res  = {1'b0, 8'hFF, 7'b1000000}; // quiet NaN
    wire [15:0] Inf_res   = {1'b0, 8'hFF, 7'h00};      // +Infinity
    wire [15:0] Zero_res  = 16'h0000;                  // Zero

    always @(*) begin
        valid     = 1'b1;
        exception = 16'h0000; // default = 0

        // NaN cases
        if ((flag_A & (Qnan | Snan)) != 0) begin
            exception = Qnan_res;
        end
        // Negative finite number (invalid)
        else if (sign_A == 1'b1 && (flag_A & (Normal | SubNormal | Zero)) != 0) begin
            exception = Qnan_res;  // sqrt(negative) = NaN
        end
        // Infinity
        else if ((flag_A & Inf) != 0) begin
            exception = Inf_res;
        end
        // Zero
        else if ((flag_A & Zero) != 0) begin
            exception = Zero_res;
        end
        // Subnormal
        else if ((flag_A & SubNormal) != 0) begin
            exception = Zero_res; // approx sqrt(subnormal) ~ 0 (or forward to datapath)
        end
        // Normal positive number → valid path
        else if ((flag_A & Normal) != 0 && sign_A == 1'b0) begin
            valid = 1'b0; // handled in datapath, not exception
        end
    end
endmodule

