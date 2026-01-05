`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2025 15:23:11
// Design Name: 
// Module Name: mult754
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

module mult754(
   input [31:0] A,
   input [31:0] B,
   input clk,
   output reg [31:0] RES
);

    reg sign_A, sign_B, sign_res;
    reg [7:0] exp_A, exp_B, exp_temp, exp_res;
    reg [23:0] mantissa_A, mantissa_B;
    reg [22:0] mantissa_res;
    reg [47:0] mantissa_temp;

    always @(*) begin
        sign_A = A[31];
        exp_A = A[30:23];
        mantissa_A = {1'b1, A[22:0]};

        sign_B = B[31];
        exp_B = B[30:23];
        mantissa_B = {1'b1, B[22:0]};

        sign_res = sign_A ^ sign_B;
        mantissa_temp = mantissa_A * mantissa_B;
        exp_temp = exp_A + exp_B - 127;

        if (mantissa_temp[47]) begin
            mantissa_res = mantissa_temp[46:24];
            exp_res = exp_temp + 1;
        end else begin
            mantissa_res = mantissa_temp[45:23];
            exp_res = exp_temp;
        end

        RES = {sign_res, exp_res, mantissa_res};
    end
endmodule

