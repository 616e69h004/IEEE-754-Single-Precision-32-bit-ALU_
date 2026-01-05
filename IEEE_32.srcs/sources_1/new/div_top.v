`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2025 18:00:56
// Design Name: 
// Module Name: div_top
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


module div_top (
    input  wire        clk,
    input  wire [31:0] A,
    input  wire [31:0] B,
    output wire [31:0] Res
);

    wire sign_A = A[31];
    wire [7:0] expo_A = A[30:23];
    wire [22:0] frac_A = A[22:0];

    wire sign_B = B[31];
    wire [7:0] expo_B = B[30:23];
    wire [22:0] frac_B = B[22:0];


    wire [6:0] flag_A, flag_B;
    special_case u_specA (
        .sign(sign_A),
        .expo(expo_A),
        .fraction(frac_A),
        .flag(flag_A)
    );

    special_case u_specB (
        .sign(sign_B),
        .expo(expo_B),
        .fraction(frac_B),
        .flag(flag_B)
    );


    wire valid;
    wire [31:0] exception_res;
    division_exception u_div_exc (
        .flag_A(flag_A),
        .flag_B(flag_B),
        .sign_A(sign_A),
        .sign_B(sign_B),
        .valid(valid),
        .exception(exception_res)
    );


    wire [31:0] normal_div_res;
    division u_div (
        .clk(clk),
        .A(A),
        .B(B),
        .Res(normal_div_res)
    );


    assign Res = (valid) ? exception_res : normal_div_res;

endmodule
