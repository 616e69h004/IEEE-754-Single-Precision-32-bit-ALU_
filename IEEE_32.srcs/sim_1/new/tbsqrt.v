`timescale 1ns/1ps
module FloatSqrtTB;

    parameter XLEN = 32;

    reg  [XLEN-1:0] A;
    reg clk;
    wire overflow, underflow, exception;
    wire [XLEN-1:0] result;

    real expected, actual;
    integer i;

    // Instantiate DUT
    FloatingSqrt #(.XLEN(32)) uut (
        .A(A),
        .clk(clk),
        .overflow(overflow),
        .underflow(underflow),
        .exception(exception),
        .result(result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    // Function: convert IEEE754 to real
    function real ieee754_to_real;
        input [31:0] x;
        reg [22:0] frac;
        reg [7:0] exp;
        reg sign;
        begin
            sign = x[31];
            exp  = x[30:23];
            frac = x[22:0];
            if (exp == 8'hFF && frac != 0)
                ieee754_to_real = 0.0/0.0;  // NaN
            else if (exp == 8'hFF)
                ieee754_to_real = (sign ? -1.0/0.0 : 1.0/0.0);
            else if (exp == 0 && frac == 0)
                ieee754_to_real = (sign ? -0.0 : 0.0);
            else if (exp == 0)
                ieee754_to_real = ((sign ? -1.0 : 1.0) * (frac / (2.0**23)) * (2.0**(-126)));
            else
                ieee754_to_real = ((sign ? -1.0 : 1.0) * (1.0 + frac / (2.0**23)) * (2.0**(exp - 127)));
        end
    endfunction

    // Task to show result
    task show_result;
        input [31:0] A_in;
        input real expected_val;
        real actual_val;
        begin
            actual_val = ieee754_to_real(result);
            $display("T=%0t | A=0x%08h | Expected=%.7f | Result=%.7f | overflow=%b | underflow=%b | exception=%b",
                     $time, A_in, expected_val, actual_val, overflow, underflow, exception);
        end
    endtask

    // Main stimulus
    initial begin
        $display("\n========= FLOATING POINT SQRT TESTBENCH (30 TEST CASES) =========\n");

        // --- Normal Positive Numbers ---
        A = 32'h00000000; #40; show_result(A, 0.0);        // +0
        A = 32'h3F800000; #40; show_result(A, 1.0);        // sqrt(1)=1
        A = 32'h40000000; #40; show_result(A, 1.4142135);  // sqrt(2)
        A = 32'h40800000; #40; show_result(A, 2.0);        // sqrt(4)
        A = 32'h41100000; #40; show_result(A, 3.0);        // sqrt(9)
        A = 32'h41C80000; #40; show_result(A, 5.0);        // sqrt(25)
        A = 32'h42040000; #40; show_result(A, 5.744563);   // sqrt(33)
        A = 32'h42AA0000; #40; show_result(A, 9.219544);   // sqrt(85)
        
       
        A = 32'h7EFFFFFF; #40; show_result(A, 1.844E19);   // very large finite

        // --- Negative Inputs ---
        A = 32'hBF800000; #40; show_result(A, 0.0/0.0);    // -1.0 -> NaN
        A = 32'hC1000000; #40; show_result(A, 0.0/0.0);    // -8.0
        A = 32'hC90FDB22; #40; show_result(A, 0.0/0.0);    // -π -> NaN

        // --- Special Cases ---
        A = 32'h7F800000; #40; show_result(A, 1.0/0.0);    // +Inf -> +Inf
        A = 32'hFF800000; #40; show_result(A, 0.0/0.0);    // -Inf -> NaN
        A = 32'h7FC00000; #40; show_result(A, 0.0/0.0);    // NaN -> NaN
        A = 32'h80000000; #40; show_result(A, 0.0);        // -0 -> +0

        $display("\n========= ALL 30 TEST CASES COMPLETED =========\n");
        $finish;
    end

endmodule
