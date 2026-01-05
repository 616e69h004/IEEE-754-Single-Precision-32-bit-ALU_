`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2025 10:18:01
// Design Name: 
// Module Name: initial_guess
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


module initial_guess_approx (
    input  wire [31:0] B,          
    output reg  [31:0] X0          
);

    
    wire sign_B     = B[31];
    wire [7:0] expo_B = B[30:23];
    wire [22:0] mant_B = B[22:0];

    
    wire is_zero      = (expo_B == 8'h00) && (mant_B == 0);
    wire is_inf       = (expo_B == 8'hFF) && (mant_B == 0);
    wire is_nan       = (expo_B == 8'hFF) && (mant_B != 0);
    wire is_subnormal = (expo_B == 8'h00) && (mant_B != 0);

    
    reg [7:0] expo_X0;
    reg [22:0] mant_X0;
    reg sign_X0;

    
    reg [7:0] lut_addr;
    reg [22:0] lut_val;

    always @(*) begin
        lut_addr = mant_B[22:18];  
        case (lut_addr)
            5'h00: lut_val = 23'h7FFFFF;  // ~1/1.0
            5'h04: lut_val = 23'h6AAAAA;  // ~1/1.25
            5'h08: lut_val = 23'h599999;  // ~1/1.5
            5'h0C: lut_val = 23'h4CCCCD;  // ~1/1.6
            5'h10: lut_val = 23'h444444;  // ~1/1.7
            5'h14: lut_val = 23'h3E38E3;  // ~1/1.8
            5'h18: lut_val = 23'h38E38E;  // ~1/1.9
            5'h1C: lut_val = 23'h333333;  // ~1/2.0
            default: lut_val = 23'h3F0000; // fallback
        endcase
    end

    
    always @(*) begin
        if (is_nan)
            X0 = 32'h7FC00000;            
        else if (is_zero)
            X0 = 32'h7F800000;            
        else if (is_inf)
            X0 = 32'h00000000;            
        else if (is_subnormal)
            X0 = 32'h7F800000;            
        else begin
            
            sign_X0 = sign_B;
            expo_X0 = 8'd253 - expo_B;  
            mant_X0 = lut_val;          

            X0 = {sign_X0, expo_X0, mant_X0};
        end
    end

endmodule