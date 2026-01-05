`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2025 18:20:37
// Design Name: 
// Module Name: division_tb
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

module tb_div_top;

    reg         clk;
    reg  [31:0] A, B;
    wire [31:0] Res;

    // Instantiate DUT
    div_top DUT (
        .clk(clk),
        .A(A),
        .B(B),
        .Res(Res)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to display the result nicely
    task show_result;
        input [31:0] A_in;
        input [31:0] B_in;
        input [31:0] R_out;
        begin
            $display("T=%0t | A=%h | B=%h | Res=%h", $time, A_in, B_in, R_out);
        end
    endtask

    // IEEE 754 constants
    localparam ZERO       = 32'h00000000; // +0.0
    localparam ONE        = 32'h3F800000; // +1.0
    localparam TWO        = 32'h40000000; // +2.0
    localparam FOUR       = 32'h40800000; // +4.0
    localparam EIGHT      = 32'h41000000; // +8.0
    localparam HALF       = 32'h3F000000; // +0.5
    localparam NEG_ONE    = 32'hBF800000; // -1.0
    localparam INF        = 32'h7F800000; // +inf
    localparam NINF       = 32'hFF800000; // -inf
    localparam NAN        = 32'h7FC00000; // NaN
    localparam SUBNORMAL  = 32'h00400000; // very small number
    localparam LARGE_NUM  = 32'h7E800000; // large finite number

    // Test sequence
    initial begin
        $display("\n--- Starting Floating-Point Division Testbench ---\n");

        // Wait a few cycles for initialization
        #10;

        // Normal cases
        A = FOUR;   B = TWO;     #20; show_result(A, B, Res); // 4 / 2 = 2
        A = EIGHT;  B = FOUR;    #20; show_result(A, B, Res); // 8 / 4 = 2
        A = ONE;    B = TWO;     #20; show_result(A, B, Res); // 0.5
        A = TWO;    B = ONE;     #20; show_result(A, B, Res); // 2
        A = LARGE_NUM; B = TWO;  #20; show_result(A, B, Res);

        // Edge / special cases
        A = ZERO;   B = ZERO;    #20; show_result(A, B, Res); // 0/0 -> NaN
        A = ONE;    B = ZERO;    #20; show_result(A, B, Res); // 1/0 -> Inf
        A = ZERO;   B = ONE;     #20; show_result(A, B, Res); // 0/1 -> 0
        A = NEG_ONE;B = TWO;     #20; show_result(A, B, Res); // -1 / 2 = -0.5
        A = ONE;    B = NEG_ONE; #20; show_result(A, B, Res); // -1
        A = INF;    B = INF;     #20; show_result(A, B, Res); // Inf/Inf -> NaN
        A = INF;    B = ONE;     #20; show_result(A, B, Res); // Inf/1 = Inf
        A = NAN;    B = ONE;     #20; show_result(A, B, Res); // NaN propagation
        A = SUBNORMAL; B = ONE;  #20; show_result(A, B, Res);

        $display("\n--- Testbench Completed ---");
        $stop;
    end

endmodule


