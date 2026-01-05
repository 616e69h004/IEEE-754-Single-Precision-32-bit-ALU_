`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2025 23:13:05
// Design Name: 
// Module Name: division_exception
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


module division_exception(
    input  wire [6:0] flag_A,
    input  wire [6:0] flag_B,
    input  wire       sign_A,
    input  wire       sign_B,
    output reg        valid,
    output reg [31:0] exception
);

    localparam QNaN    = 7'b0000001;
    localparam SNaN    = 7'b0000010;
    localparam INF     = 7'b0000100;
    localparam ZERO    = 7'b0001000;
    localparam SUBNORM = 7'b0010000;
    localparam NORMAL  = 7'b0100000;

    
    localparam [31:0] QNAN_res = 32'h7FC00000; // quiet NaN (positive)
    localparam [31:0] INF_res  = 32'h7F800000; // +Inf
    localparam [31:0] NINF_res = 32'hFF800000; // -Inf
    localparam [31:0] ZERO_res = 32'h00000000; // +0

    wire A_is_QNaN = (flag_A & QNaN) != 0;
    wire A_is_SNaN = (flag_A & SNaN) != 0;
    wire A_is_NaN  = A_is_QNaN || A_is_SNaN;
    wire B_is_NaN  = ((flag_B & QNaN) != 0) || ((flag_B & SNaN) != 0);
    wire A_is_Inf  = (flag_A & INF) != 0;
    wire B_is_Inf  = (flag_B & INF) != 0;
    wire A_is_Zero = (flag_A & ZERO) != 0;
    wire B_is_Zero = (flag_B & ZERO) != 0;
    wire A_is_NormalOrSub = ((flag_A & NORMAL) != 0) || ((flag_A & SUBNORM) != 0);
    wire B_is_NormalOrSub = ((flag_B & NORMAL) != 0) || ((flag_B & SUBNORM) != 0);

    always @(*) begin
        valid = 1'b1;       
        exception = 32'h00000000;

        if (A_is_NaN || B_is_NaN) begin
            exception = QNAN_res;
        end
        
        else if (A_is_Inf && B_is_Inf) begin
            exception = QNAN_res;
        end
        
        else if (A_is_Inf && !B_is_Inf) begin
            exception = (sign_A ^ sign_B) ? NINF_res : INF_res;
        end
        
        else if (!A_is_Inf && B_is_Inf) begin
            exception = (sign_A ^ sign_B) ? 32'h80000000 : 32'h00000000;
            if ((sign_A ^ sign_B) == 1'b1) begin 
                exception = 32'h80000000;
            end else begin 
            exception = 32'h00000000;
            end
        end
        else if (A_is_Zero && B_is_Zero) begin
            exception = QNAN_res;
        end
        else if (A_is_NormalOrSub && B_is_Zero) begin
            exception = (sign_A ^ sign_B) ? NINF_res : INF_res;
        end
        else if (A_is_Zero && B_is_NormalOrSub) begin
            if ((sign_A ^ sign_B) == 1'b1) begin
            exception = 32'h80000000;
            end else begin 
            exception = 32'h00000000;
            end
        end
        else begin
            valid = 1'b0;
            exception = 32'h00000000;
        end
    end
endmodule
