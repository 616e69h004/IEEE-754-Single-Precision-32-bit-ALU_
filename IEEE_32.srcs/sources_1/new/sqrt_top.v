`timescale 1ns/1ps
module FloatingSqrt #(parameter XLEN = 32)
(
    input  wire [XLEN-1:0] A,
    input  wire             clk,
    output wire             overflow,
    output wire             underflow,
    output wire             exception,
    output wire [XLEN-1:0]  result
);

    // ------------------------------------------------
    // Field extraction
    // ------------------------------------------------
    wire Sign       = A[31];
    wire [7:0] Exponent  = A[30:23];
    wire [22:0] Mantissa = A[22:0];

    // ------------------------------------------------
    // Special case detection
    // ------------------------------------------------
    wire [6:0] flag_A;
    special_case u_specA (
        .sign(Sign),
        .expo(Exponent),
        .fraction(Mantissa),
        .flag(flag_A)
    );

    // ------------------------------------------------
    // Exception handler
    // ------------------------------------------------
    wire valid;
    wire [15:0] exception16;
    sqrt_exception excp (
        .flag_A(flag_A),
        .sign_A(Sign),
        .valid(valid),
        .exception(exception16)
    );

    // Expand 16-bit exception result to IEEE754 32-bit
    wire [31:0] exception_res = {exception16[15], exception16[14:7], {exception16[6:0], 16'b0}};

    // ------------------------------------------------
    // Newton-Raphson datapath for sqrt(mantissa)
    // ------------------------------------------------
    wire [XLEN-1:0] x0, x1, x2, x3;
    wire [XLEN-1:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp;
    wire [7:0] Exp_half;
    wire remainder;
    wire pos;

    // Constants
    localparam [31:0] sqrt_1by05 = 32'h3FB504F3;  // 1/sqrt(0.5)
    localparam [31:0] sqrt_2     = 32'h3FB504F3;  // sqrt(2)
    localparam [31:0] sqrt_1by2  = 32'h3F3504F3;  // 1/sqrt(2)
    assign x0 = 32'h3F5A827A;                     // Initial guess

    // Iteration 1
    FloatingDivision D1 (.A({1'b0,8'd126,Mantissa}), .B(x0), .result(temp1));
    ADD_SUB A1 (.A(temp1), .B(x0), .OP(1'b0), .out(temp2));
    assign x1 = {temp2[31], temp2[30:23]-1, temp2[22:0]};

    // Iteration 2
    FloatingDivision D2 (.A({1'b0,8'd126,Mantissa}), .B(x1), .result(temp3));
    ADD_SUB A2 (.A(temp3), .B(x1), .OP(1'b0), .out(temp4));
    assign x2 = {temp4[31], temp4[30:23]-1, temp4[22:0]};

    // Iteration 3
    FloatingDivision D3 (.A({1'b0,8'd126,Mantissa}), .B(x2), .result(temp5));
    ADD_SUB A3 (.A(temp5), .B(x2), .OP(1'b0), .out(temp6));
    assign x3 = {temp6[31], temp6[30:23]-1, temp6[22:0]};

    // Multiply by scaling constant
    mult754 M1 (.A(x3), .B(sqrt_1by05), .RES(temp7));

    // ------------------------------------------------
    // Exponent adjustment: unbiased halve of exponent
    // ------------------------------------------------
    wire signed [8:0] exp_unbiased = $signed({1'b0,Exponent}) - 127;
    wire signed [8:0] exp_half = exp_unbiased >>> 1;
    assign remainder = exp_unbiased[0];
    wire [7:0] Exp_2 = exp_half + 127;

    assign temp = {temp7[31], Exp_2 + temp7[30:23] - 127, temp7[22:0]};
    mult754 M2 (.A(temp), .B(sqrt_2), .RES(temp8));

    wire [31:0] normal_res = remainder ? temp8 : temp;

    // ------------------------------------------------
    // Final selection (exception or datapath)
    // ------------------------------------------------
    assign result = valid ? exception_res : normal_res;

    // ------------------------------------------------
    // Flags (placeholder for now)
    // ------------------------------------------------
    assign overflow  = 1'b0;
    assign underflow = 1'b0;
    assign exception = valid;

endmodule
