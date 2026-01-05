`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2025 15:21:06
// Design Name: 
// Module Name: ADD_SUB
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


module ADD_SUB(
    input [31:0] A, B,
    input OP,
    output [31:0] out
);

wire sign_a, sign_b, sign_res, c_out;
wire [7:0] exp_a, exp_b, e_g, e_s, exp_diff, exp_out_int, exp_out_int2, exp_out_int3, exp_out;
wire [4:0] position, position1;
wire [23:0] mant_a, mant_b, mant_g, mant_s_int, mant_s, sum, mant_add, mant_sub_int, mant_sub, mant_out;
wire [22:0] mant_sub_f;

assign sign_a = A[31];
assign sign_b = B[31];
assign exp_a = A[30:23];
assign exp_b = B[30:23];
assign mant_a = {1'b1, A[22:0]};  
assign mant_b = {1'b1, B[22:0]};  


comparision comp1 (
    .sign_a(sign_a), .sign_b(sign_b), .OP(OP), 
    .exp_a(exp_a), .exp_b(exp_b), 
    .mant_a(mant_a), .mant_b(mant_b), 
    .SEL(SEL), .sign_res(sign_res), .sign_out(sign_out)
);

assign e_g = SEL ? exp_a : exp_b;
assign e_s = SEL ? exp_b : exp_a;
assign mant_g = SEL ? mant_a : mant_b;
assign mant_s_int = SEL ? mant_b : mant_a;

assign exp_diff = e_g - e_s;
assign mant_s = mant_s_int >> exp_diff[4:0];  


adder24 a1 (.A(mant_g), .B(mant_s), .Sum(sum), .C_out(c_out));

assign mant_add = c_out ? sum[23:1] : sum[22:0]; 


adder8 a2 (.A({7'b0, c_out}), .B(e_g), .Sum(exp_out_int));


assign mant_sub_int = mant_g - mant_s;
assign zero = (mant_sub_int == 0) ? 1 : 0;  


find1 f1(.in(mant_sub_int), .position(position));


assign position1 = 5'b11000 - position;
assign mant_sub = mant_sub_int << position1;
assign mant_sub_f = mant_sub[23:1];
assign mant_out = sign_res ? mant_sub_f : mant_add;


assign exp_out_int2 = e_g - position1 + 1'b1;
assign exp_out_int3 = zero ? 8'b0 : exp_out_int2;


assign exp_out = sign_res ? exp_out_int3 : exp_out_int;
assign out = {sign_out, exp_out, mant_out[22:0]};  

endmodule


module comparision(
    input sign_a, sign_b, OP,
    input [7:0] exp_a, exp_b,
    input [23:0] mant_a, mant_b,
    output SEL, sign_res, sign_out
);
   wire e_g, m_g, i_g, f_g, sel_int, sign_int_b;
   wire s_i;  
   
   
   assign SEL = (exp_a > exp_b) ? 1 : 0;
   assign e_g = (SEL) ? sign_a : sign_b;
   assign m_g = (mant_a > mant_b) ? sign_a : sign_b;
   assign i_g = (SEL) ? e_g : m_g;
   
   
   assign s_i = ~SEL & OP;
   assign f_g = s_i ? ~i_g : i_g;
   assign sign_int_b = OP ? ~sign_b : sign_b;
   assign sign_res = sign_int_b ^ sign_a; 
   assign sign_out = sign_res ? f_g : sign_a;
endmodule


module adder24 (
    input [23:0] A,         
    input [23:0] B,        
    output [23:0] Sum,     
    output C_out
);

    wire [24:0] full_sum;  
    
kogge_stone_24bit_adder add( .A(A), .B(B), .Sum(Sum), .Cout(C_out));

    
endmodule


module adder8 (
    input [7:0] A,         
    input [7:0] B,        
    output [7:0] Sum    
);

    wire [8:0] full_sum; 
    
    assign full_sum = A + B;  

    assign Sum = full_sum[7:0];  
endmodule


module find1 (
    input [23:0] in,          
    output reg [4:0] position 
);

    integer i;

    always @(*) begin
        position = 5'b11111;  
        
        for (i = 23; i >= 0; i = i - 1) begin
            if (in[i] == 1'b1) begin
                position = i[4:0]; 
            end
        end
    end
endmodule

module kogge_stone_24bit_adder (
    input [23:0] A,   
    input [23:0] B,  
    output [23:0] Sum, 
    output Cout      
);

    wire [23:0] G, P;   
    wire [23:0] C;     

 
    genvar i;
    generate
        for (i = 0; i < 24; i = i + 1) begin
            assign G[i] = A[i] & B[i];   
            assign P[i] = A[i] ^ B[i];   
        end
    endgenerate

    
  
    wire [23:0] G1, P1;
    generate
        for (i = 1; i < 24; i = i + 1) begin
            assign G1[i] = G[i] | (P[i] & G[i-1]);  
            assign P1[i] = P[i] & P[i-1];           
        end
        assign G1[0] = G[0];  
        assign P1[0] = P[0];
    endgenerate

  
    wire [23:0] G2, P2;
    generate
        for (i = 2; i < 24; i = i + 1) begin
            assign G2[i] = G1[i] | (P1[i] & G1[i-2]);
            assign P2[i] = P1[i] & P1[i-2];
        end
        assign G2[1:0] = G1[1:0]; 
        assign P2[1:0] = P1[1:0];
    endgenerate

  
    wire [23:0] G3, P3;
    generate
        for (i = 4; i < 24; i = i + 1) begin
            assign G3[i] = G2[i] | (P2[i] & G2[i-4]);
            assign P3[i] = P2[i] & P2[i-4];
        end
        assign G3[3:0] = G2[3:0];  
        assign P3[3:0] = P2[3:0];
    endgenerate

  
    wire [23:0] G4, P4;
    generate
        for (i = 8; i < 24; i = i + 1) begin
            assign G4[i] = G3[i] | (P3[i] & G3[i-8]);
            assign P4[i] = P3[i] & P3[i-8];
        end
        assign G4[7:0] = G3[7:0];  
        assign P4[7:0] = P3[7:0];
    endgenerate
    
 
    wire [23:0] G5, P5;
    generate
        for (i = 16; i < 24; i = i + 1) begin
            assign G5[i] = G4[i] | (P4[i] & G4[i-16]);
            assign P5[i] = P4[i] & P4[i-16];
        end
        assign G5[15:0] = G4[15:0]; 
        assign P5[15:0] = P4[15:0];
    endgenerate

    assign C[0] = 1'b0;  
    generate
        for (i = 1; i < 24; i = i + 1) begin
            assign C[i] = G5[i-1];  
        end
    endgenerate
    assign Cout = G5[23] ; 

   
    generate
        for (i = 1; i < 24; i = i + 1) begin
            assign Sum[i] = P[i] ^ C[i]; 
            
        end
        assign Sum[0] = P[0] ;
    endgenerate
    endmodule
