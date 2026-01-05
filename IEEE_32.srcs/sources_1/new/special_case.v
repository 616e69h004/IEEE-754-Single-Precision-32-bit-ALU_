`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2025 21:10:34
// Design Name: 
// Module Name: special_case
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


module special_case(
    input  wire       sign,
    input  wire [7:0] expo,
    input  wire [22:0] fraction,
    output reg  [6:0] flag
);

    localparam QNaN    = 7'b0000001;
    localparam SNaN    = 7'b0000010;
    localparam INF     = 7'b0000100;
    localparam ZERO    = 7'b0001000;
    localparam SUBNORM = 7'b0010000;
    localparam NORMAL  = 7'b0100000;

    always @(*) begin
        flag = 7'b0000000;
        if (expo == 8'hFF && fraction != 23'b0) begin
            if (fraction[22] == 1'b1) begin
                flag = QNaN;
            end else begin
                flag = SNaN;
            end
        end
        else if (expo == 8'hFF && fraction == 23'b0) begin
            flag = INF;
        end
        else if (expo == 8'h00 && fraction == 23'b0) begin
            flag = ZERO;
        end
        else if (expo == 8'h00 && fraction != 23'b0) begin
            flag = SUBNORM;
        end
        else begin
            flag = NORMAL;
        end
    end
endmodule

